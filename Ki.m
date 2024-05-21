clear;
clc;
disp('Silakan pilih gambar watermark');
[filename, pathname] = uigetfile('*.jpg', 'Pilih Gambar Watermark');
pathfile = fullfile(pathname, filename);
markbefore = imread(pathfile); 

disp('Silakan pilih gambar operator');
[filename2, pathname2] = uigetfile('*.jpg', 'Pilih Gambar Operator');
pathfile2 = fullfile(pathname2, filename2);
image = imread(pathfile2); 

markbefore2 = rgb2gray(markbefore);
mark = im2bw(markbefore2); 

figure(1);
subplot(2,3,1); 
imshow(mark), title('Watermark'); 

marksize = size(mark);
rm = marksize(1); 
cm = marksize(2); 
I = mark;

alpha = 30; 
k1 = randn; % Single random value
k2 = randn; % Single random value

subplot(2,3,2), imshow(image, []), title('Gambar Vektor'); 

yuv = rgb2ycbcr(image); 
Y = yuv(:,:,1); 
U = yuv(:,:,2); 
V = yuv(:,:,3);

[rm2, cm2] = size(U); 
before = blockproc(U, [8 8], @(block_struct) dct2(block_struct.data)); 
after = before; 

for i = 1:rm 
    for j = 1:cm
        x = (i-1)*8 + 1; % Adjusted to match block size
        y = (j-1)*8 + 1;
        % Ensure we are within bounds
        if x+7 <= rm2 && y+7 <= cm2
            if mark(i,j) == 1
                k = k1;
            else
                k = k2;
            end
            % Embed watermark by modifying a single DCT coefficient
            after(x,y) = after(x,y) + alpha * k;
        end
    end
end

result = blockproc(after, [8 8], @(block_struct) idct2(block_struct.data)); 
yuv_after = cat(3, Y, result, V); 
rgb = ycbcr2rgb(yuv_after); 
imwrite(rgb, 'markresult.jpg', 'jpg'); 

subplot(2,3,3), imshow(rgb, []), title('Gambar yang Ditandai Air'); 

disp('Silakan pilih cara menyerang gambar');
disp('1. Tambahkan white noise');
disp('2. Pemotongan sebagian gambar');
disp('3. Putar gambar sepuluh derajat');
disp('4. Kompres gambar');
disp('5. Tampilkan tanda air yang diekstraksi tanpa memproses gambar');
choice = input('Silakan masukkan pilihan: ');

switch choice
    case 1
        % Add white noise
        noisy_image = imnoise(rgb, 'gaussian', 0, 0.01);
        figure(2), imshow(noisy_image, []), title('Gambar dengan White Noise');
    case 2
        % Partial crop
        cropped_image = imcrop(rgb, [50, 50, size(rgb, 2)-100, size(rgb, 1)-100]);
        figure(2), imshow(cropped_image, []), title('Gambar yang Dipotong');
    case 3
        % Rotate image
        rotated_image = imrotate(rgb, 10);
        figure(2), imshow(rotated_image, []), title('Gambar yang Diputar 10 Derajat');
    case 4
        % Compress image
        imwrite(rgb, 'compressed.jpg', 'jpg', 'Quality', 10);
        compressed_image = imread('compressed.jpg');
        figure(2), imshow(compressed_image, []), title('Gambar yang Dikompres');
    case 5
        % Display the watermark without processing
        figure(2), imshow(mark, []), title('Tanda Air yang Diekstrak');
    otherwise
        disp('Pilihan tidak valid. Menampilkan tanda air yang diekstrak.');
        figure(2), imshow(mark, []), title('Tanda Air yang Diekstrak');
end