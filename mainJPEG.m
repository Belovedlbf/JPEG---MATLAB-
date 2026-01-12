close all;
clearvars; % 替换clear all（新版本推荐）

% 交互式选择输入图像文件
[fn, pn] = uigetfile({'*.bmp;*.jpg;*.jpeg;*.png', 'Image files (*.bmp, *.jpg, *.png)'; '*.*', 'All Files (*.*)'}, '选择要压缩的图片');
if isequal(fn, 0)
    error('未选择文件，程序已终止。');
end
input_filename = fullfile(pn, fn);

% 读取图像（保留一个 uint8 版本用于显示/保存，另一个 double 版本用于压缩流程）
original_image_uint8 = imread(input_filename);
original_image = double(original_image_uint8);

% RGB转YCBCR并压缩（会询问质量）
[compress_image_Y, compress_image_CB, compress_image_CR] = RGB2YCBCR(original_image);

% ---- 将压缩结果写入自定义 .lbf 文件（替代原来的 .mat 保存） ----
lbf_filename = 'test2_compressed.lbf';
try
    write_lbf(lbf_filename, compress_image_Y, compress_image_CB, compress_image_CR);
catch ME
    warning('写入 .lbf 文件时出错: %s\n尝试回退保存为 .mat 文件。', ME.message);
    save('test2_compressed.mat', 'compress_image_Y', 'compress_image_CB', 'compress_image_CR');
    lbf_filename = 'test2_compressed.mat';
end

% 计算并显示原始文件和压缩文件大小（字节）
info_orig = dir(input_filename);
if isempty(info_orig)
    error('找不到原始文件: %s，请确认路径和文件名。', input_filename);
end
% 如果有多个条目，尝试找到完全匹配的文件名，否则使用第一个
if numel(info_orig) > 1
    idx = find(strcmp({info_orig.name}, fn), 1);
    if isempty(idx)
        idx = 1;
    end
else
    idx = 1;
end
original_file_bytes = info_orig(idx).bytes;

info_comp = dir(lbf_filename);
if isempty(info_comp)
    error('无法找到已保存的压缩文件: %s', lbf_filename);
end
% 处理多个匹配的情况（同上）
if numel(info_comp) > 1
    idxc = find(strcmp({info_comp.name}, lbf_filename), 1);
    if isempty(idxc)
        idxc = 1;
    end
else
    idxc = 1;
end
compressed_file_bytes = info_comp(idxc).bytes;

compression_ratio = original_file_bytes / max(1, compressed_file_bytes); % 防止除以0
fprintf('原始文件字节: %d\n', original_file_bytes);
fprintf('压缩(.lbf)文件字节: %d\n', compressed_file_bytes);
fprintf('近似压缩比 (原始/压缩) = %.2f\n', compression_ratio);

% ---- 从 .lbf 读取并解压恢复图像 ----
S = read_lbf(lbf_filename);

% 确认读取结果包含所需通道
if ~isfield(S, 'compress_image_Y') || ~isfield(S, 'compress_image_CB') || ~isfield(S, 'compress_image_CR')
    error('从 %s 读取的文件中缺少 Y/CB/CR 通道，请检查文件或读取函数。', lbf_filename);
end

image_recovered = YCBCR2RGB(S.compress_image_Y, S.compress_image_CB, S.compress_image_CR);

% 尺寸信息
[m1, m2, m3] = size(original_image_uint8);
sizevector1 = size(original_image_uint8);
sizevector2 = size(image_recovered);

% 显示原始/恢复图像
figure;
subplot(121);
display_image = original_image_uint8;
imdisplay(display_image);
title('原始图像');

subplot(122);
display_image = image_recovered;
imdisplay(display_image);
title('解压/恢复后图像');

% 保存恢复图像（这里保存为 BMP，用于目视评估）
recovered_filename = sprintf('test2_recovered.bmp');
imwrite(image_recovered, recovered_filename);
fprintf('已保存恢复图像到 %s\n', recovered_filename);

% 显示压缩流长度估算（使用 .lbf/结构中的 realsize 字段）
compress_size_estimate = double(S.compress_image_Y.realsize) + double(S.compress_image_CB.realsize) + double(S.compress_image_CR.realsize);
ratiomesg = sprintf('压缩流样本数估算 = %d, 压缩比(像素数/样本数) = %6.2f\n', compress_size_estimate, (m1*m2*m3)/max(1,compress_size_estimate));
disp(ratiomesg);