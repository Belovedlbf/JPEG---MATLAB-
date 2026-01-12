function recover_image = YCBCR2RGB(original_image_Y,original_image_CB,original_image_CR)
    % 解压通道
    Y = Decompress(original_image_Y);
    CB = Decompress(original_image_CB);
    CR = Decompress(original_image_CR);
    
    figure;
    subplot(131),imshow(uint8(Y)),title('Y通道 逆量化/逆DCT 后');
    subplot(132),imshow(uint8(CB)),title('CB通道 逆量化/逆DCT 后');
    subplot(133),imshow(uint8(CR)),title('CR通道 逆量化/逆DCT 后');
    
    % 将 Y/Cb/Cr 转为 double（确保数值计算正常）
    Y = double(Y);
    CB = double(CB);
    CR = double(CR);
    
    % 使用全范围（full-range）Y'CbCr -> RGB 逆变换
    % 这是与 RGB2YCBCR 中 Y = 0.299*R + ... 对应的逆变换
    R = Y + 1.402   * (CR - 128);
    G = Y - 0.344136 * (CB - 128) - 0.714136 * (CR - 128);
    B = Y + 1.772   * (CB - 128);
    
    % 裁剪到有效像素范围 0-255 并转为 uint8
    R = round(R); G = round(G); B = round(B);
    R(R < 0) = 0;   R(R > 255) = 255;
    G(G < 0) = 0;   G(G > 255) = 255;
    B(B < 0) = 0;   B(B > 255) = 255;
    
    figure;
    subplot(131),imshow(uint8(R)),title('R 通道 恢复');
    subplot(132),imshow(uint8(G)),title('G 通道 恢复');
    subplot(133),imshow(uint8(B)),title('B 通道 恢复');
    
    % 合并为 RGB 图像并返回
    RGB = zeros(size(Y,1), size(Y,2), 3);
    RGB(:,:,1) = R;
    RGB(:,:,2) = G;
    RGB(:,:,3) = B;
    RGB = uint8(RGB);  
    recover_image = RGB;
    
    figure;
    imshow(RGB),title('恢复后的 RGB 图像');
end