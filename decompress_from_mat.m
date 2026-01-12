% decompress_from_lbf.m
% 将 test2_compressed.lbf 解压并保存重建图像（替代原 decompress_from_mat.m）
%
% 使用说明：
% - 请确保 read_lbf.m 和 YCBCR2RGB.m 在 MATLAB 路径或同一目录下。
% - 默认读取文件名为 'test2_compressed.lbf'，输出保存为 'recovered_from_lbf.bmp'。
% - 若要修改输入/输出文件名，可直接编辑下面的变量。

% 输入/输出文件名（按需修改）
lbfFilename = 'test2_compressed.lbf';
outFilename = 'recovered_from_lbf.bmp';

% 检查文件是否存在
if ~exist(lbfFilename, 'file')
    error('找不到 %s，请确认路径。', lbfFilename);
end

% 尝试读取 .lbf 文件
fprintf('正在读取 %s ...\n', lbfFilename);
try
    S = read_lbf(lbfFilename);
catch ME
    error('读取 %s 时出错：%s\n请确认 read_lbf.m 可用并且文件格式正确。', lbfFilename, ME.message);
end

% 显示读取到的通道信息（调试用）
fprintf('读取到的结构字段：\n');
disp(fieldnames(S));

% 确认包含 Y/CB/CR 通道
if isfield(S, 'compress_image_Y') && isfield(S, 'compress_image_CB') && isfield(S, 'compress_image_CR')
    cy = S.compress_image_Y;
    ccb = S.compress_image_CB;
    ccr = S.compress_image_CR;
else
    error('读取的 .lbf 文件中未包含 compress_image_Y/compress_image_CB/compress_image_CR 字段。');
end

% 调用解压（YCBCR2RGB 内部会调用 Decompress）
fprintf('开始解压并重建图像（调用 YCBCR2RGB）...\n');
try
    recovered = YCBCR2RGB(cy, ccb, ccr);
catch ME
    error('解压/重建图像时出错：%s', ME.message);
end

% 显示并保存结果
figure; imshow(recovered); title('Recovered image from .lbf');
imwrite(recovered, outFilename);
fprintf('已保存恢复图像到 %s\n', outFilename);