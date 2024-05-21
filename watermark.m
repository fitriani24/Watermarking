clear;
clc;

% Pemilihan gambar watermark
disp('Silakan pilih gambar watermark');
[filename, pathname] = uigetfile('*.jpg', 'Pilih gambar watermark');
if isequal(filename, 0)
    disp('User selected Cancel');
    return;
else
    pathfile = fullfile(pathname, filename);
    markbefore = imread(pathfile);
end

% Pemilihan gambar target
disp('Silakan pilih gambar target');
[filename2, pathname2] = uigetfile('*.jpg', 'Pilih gambar target');
if isequal(filename2, 0)
    disp('User selected Cancel');
    return;
else
    pathfile2 = fullfile(pathname2, filename2);
    image = imread(pathfile2);
end

% Mengonversi watermark menjadi grayscale dan biner
markbefore2 = rgb2gray(markbefore);
mark = imbinarize(markbefore2);

figure;
subplot(2,3,1);
imshow(mark), title('Watermark');

marksize = size(mark);
rm = marksize(1);
cm = marksize(2);
I = mark;
alpha = 30;
k1 = randn(1,64); % Menggunakan vektor dengan ukuran 64 (8x8)
k2 = randn(1,64); % Menggunakan vektor dengan ukuran 64 (8x8)

subplot(2,3,2), imshow(image, []), title('Gambar Vektor');
yuv = rgb2ycbcr(image);
Y = yuv(:,:,1);
U = yuv(:,:,2);
V = yuv(:,:,3);

before = blkproc(U, [8 8], @dct2);
after = before;

for i = 1:rm
    for j = 1:cm
        x = (i-1)*8 + 1;
        y = (j-1)*8 + 1;
        if x+7 <= size(U, 1) && y+7 <= size(U, 2)
            if mark(i,j) == 1
                k = k1;
            else
                k = k2;
            end
            block = after(x:x+7, y:y+7);
            block = block + alpha * reshape(k, [8, 8]);
            after(x:x+7, y:y+7) = block;
        end
    end
end

result = blkproc(after, [8 8], @idct2);
yuv_after = cat(3, Y, result, V);
rgb = ycbcr2rgb(yuv_after);
imwrite(rgb, 'markresult.jpg', 'jpg'); % Simpan gambar yang diberi watermark

subplot(2,3,3), imshow(rgb, []), title('Gambar yang Ditandai Air');

% Pemilihan jenis serangan
disp('Silakan pilih cara menyerang gambar');
disp('1. Tambahkan white noise');
disp('2. Pemotongan sebagian gambar');
disp('3. Putar gambar sepuluh derajat');
disp('4. Kompres gambar');
disp('5. Tampilkan tanda air yang diekstraksi tanpa memproses gambar');
disp('Masukkan nomor lain untuk menampilkan tanda air yang diekstrak secara langsung');
choice = input('Silakan masukkan pilihan: ');

switch choice
    case 1
        result_1 = rgb;
        noise = 10 * randn(size(result_1)); 
        result_1 = double(result_1) + noise; 
        withmark = uint8(result_1);
        subplot(2,3,4);
        imshow(withmark, []);
        title('Gambar setelah menambahkan white noise');
    case 2
        result_2 = rgb;
        A = result_2(:,:,1);
        B = result_2(:,:,2);
        C = result_2(:,:,3);
        A(1:64,1:400) = 512; 
        B(1:64,1:400) = 512; 
        C(1:64,1:400) = 512; 
        result_2 = cat(3, A, B, C);
        subplot(2,3,4);
        imshow(result_2);
        title('Gambar di atas terpotong');
        withmark = result_2;
    case 3
        result_3 = rgb;
        result_3 = imrotate(rgb, 10, 'bilinear', 'crop'); 
        subplot(2,3,4);
        imshow(result_3);
        title('Gambar setelah rotasi 10 derajat');
        withmark = result_3;
    case 4
        [cA1, cH1, cV1, cD1] = dwt2(rgb, 'Haar'); 
        cA1 = compress(cA1);
        cH1 = compress(cH1);
        cV1 = compress(cV1);
        cD1 = compress(cD1);
        result_4 = idwt2(cA1, cH1, cV1, cD1, 'Haar');
        result_4 = uint8(result_4);
        subplot(2,3,4);
        imshow(result_4);
        title('Gambar setelah kompresi wavelet');
        withmark = result_4;
    case 5
        subplot(2,3,4);
        imshow(rgb, []);
        title('Gambar tanda air tanpa cetakan');
        withmark = rgb;
    otherwise
        disp('Pilihan tidak valid, gambar tidak diserang, dan tanda air langsung diekstraksi.');
        subplot(2,3,4);
        imshow(rgb, []);
        title('Gambar tanda air tanpa cetakan');
        withmark = rgb;
end

% Ekstraksi watermark
U_2 = withmark(:,:,2); 
after_2 = blkproc(U_2, [8, 8], @dct2); 
mark_2 = zeros(rm, cm); % Inisialisasi mark_2

for i = 1:rm
    for j = 1:cm
        x = (i-1) * 8;
        y = (j-1) * 8;
        if x+7 <= size(U_2, 1) && y+7 <= size(U_2, 2)
            block = after_2(x+1:x+8, y+1:y+8); % Ekstrak blok
            p = reshape(block, 1, []); % Bentuk ulang ke 1D untuk korelasi
            if corr2(p, reshape(k1, 1, [])) > corr2(p, reshape(k2, 1, []))
                mark_2(i, j) = 1; 
            else
                mark_2(i, j) = 0;
            end
        end
    end
end

subplot(2,3,5);
imshow(mark_2), title('Tanda air yang diekstraksi');
subplot(2,3,6);
imshow(mark), title('Tanda air asli yang disematkan');