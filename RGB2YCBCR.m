function [Compress_image_Y,Compress_image_CB,Compress_image_CR] = RGB2YCBCR(original_image)

%亮度通道量化表
Luminious=[
	16 11 10 16  24 40   51  61;  
	12 12 14 19  26 58   60  55;  
	14 13 16 24  40 57   69  55;  
	14 17 22 29  51 87   80  62;  
	18 22 37 56  68 109 103  77;  
	24 35 55 64  81 104 113  92;  
	49 64 78 87 103 121 120 101;  
	72 92 95 98 112 100 103  99;
];  
 %色度通道量化表
chromanious=[
     17 18 24 47 99 99 99 99;  
     18 21 26 66 99 99 99 99;  
     24 26 56 99 99 99 99 99;  
     47 66 99 99 99 99 99 99;  
     99 99 99 99 99 99 99 99;  
     99 99 99 99 99 99 99 99;  
     99 99 99 99 99 99 99 99;  
     99 99 99 99 99 99 99 99;
];  
quality = input('请输入压缩比例:(0<quality<=100)');

%调整压缩率
if quality < 100 && quality> 0
    Luminious_Q = round(Luminious .* (ones(8) * (quality/100))); %四舍五入
    Luminious_Q = double(Luminious_Q);
elseif quality == 100
    Luminious_Q = Luminious;
else
    error('quality 必须在 (0,100] 范围内');
end
% 保证量化表最小为1，避免除以0
Luminious_Q(Luminious_Q < 1) = 1;

RGB_image=original_image;
R=RGB_image(:,:,1);
G=RGB_image(:,:,2);
B=RGB_image(:,:,3);
figure;
subplot(131),imshow(uint8(R)),title('R通道');
subplot(132),imshow(uint8(G)),title('G通道');
subplot(133),imshow(uint8(B)),title('B通道');
R=double(R);
G=double(G);
B=double(B);
Y=0.299*R+0.587*G+0.114*B;
CB=-0.1687*R-0.3313*G+0.5*B+128;
CR=0.5*R-0.4187*G-0.0813*B+128;
[x,y]=size(Y);

figure;
subplot(131),imshow(uint8(Y)),title('Y通道');
subplot(132),imshow(uint8(CB)),title('CB通道');
subplot(133),imshow(uint8(CR)),title('CR通道');

Y=double(Y);
CB=double(CB);
CR=double(CR);

T=dctmtx(8);%DCT变换

% 使用 blockproc 替代已弃用的 blkproc
Y1 = blockproc(Y, [8 8], @(blk) T * blk.data * T');  
CB1 = blockproc(CB, [8 8], @(blk) T * blk.data * T');  
CR1 = blockproc(CR, [8 8], @(blk) T * blk.data * T');  
figure;
subplot(131),imshow(Y1, []),title('Y通道分块结果');
subplot(132),imshow(CB1, []),title('CB通道分块结果');
subplot(133),imshow(CR1, []),title('CR通道分块结果');

Y_Quantization = blockproc(Y1, [8 8], @(blk) round(blk.data ./ Luminious_Q));  
CB_Quantization = blockproc(CB1, [8 8], @(blk) round(blk.data ./ chromanious));  
CR_Quantization = blockproc(CR1, [8 8], @(blk) round(blk.data ./ chromanious));  

figure;
subplot(131),imshow(Y_Quantization, []),title('Y通道量化结果');
subplot(132),imshow(CB_Quantization, []),title('CB通道量化结果');
subplot(133),imshow(CR_Quantization, []),title('CR通道量化结果');

% 将量化后的数据和相应量化表��起传入 Compress（Compress 会把量化表保存到结构体）
Compress_image_Y = Compress(Y_Quantization,1,Luminious_Q);
Compress_image_CB = Compress(CB_Quantization,2,chromanious);
Compress_image_CR = Compress(CR_Quantization,3,chromanious);
end