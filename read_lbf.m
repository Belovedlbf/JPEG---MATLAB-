function S = read_lbf(filename)
% READ_LBF 读取 .lbf 文件并返回结构体 S，包含 compress_image_Y/CB/CR（若存在）
% S.compress_image_Y 等可以直接传入 Decompress()
%
% Usage:
% S = read_lbf('out.lbf');
% cy = S.compress_image_Y;

fid = fopen(filename, 'r');
if fid == -1
    error('无法打开文件读取: %s', filename);
end
cleanup = onCleanup(@() fclose(fid));

% 读取并检查 magic/version
magic = char(fread(fid, 3, 'uint8')');
if ~strcmp(magic, 'LBF')
    error('文件不是 LBF 格式 (magic mismatch)');
end
version = fread(fid, 1, 'int32');
if isempty(version)
    error('无法读取版本信息');
end
if version ~= 1
    warning('读取版本 %d（预期 1），尝试兼容读取', version);
end

channel_count = fread(fid, 1, 'int32');
if isempty(channel_count) || channel_count < 1
    error('无效的通道计数');
end

S = struct();
for k = 1:channel_count
    ch_id = fread(fid, 1, 'int32');
    rows = fread(fid, 1, 'int32');
    cols = fread(fid, 1, 'int32');
    numblocks = fread(fid, 1, 'int32');
    realsize = fread(fid, 1, 'int32');
    eob = fread(fid, 1, 'int32');

    rlen = fread(fid, 1, 'int32');
    if rlen > 0
        rvec = fread(fid, double(rlen), 'int32')';
    else
        rvec = [];
    end

    qflag = fread(fid, 1, 'uint8');
    if qflag == 1
        qt = fread(fid, 64, 'uint16')';
        qt = reshape(double(qt), 8, 8); % row-major -> 8x8
    else
        qt = [];
    end

    % 构造与 Compress 输出兼容的结构
    y = struct();
    y.realsize = double(realsize);
    y.size = uint16([double(rows) double(cols)]);
    y.numblocks = uint16(double(numblocks));
    y.r = double(rvec);            % 保持数值型（Decompress 使用时会处理）
    y.channel = double(ch_id);
    if ~isempty(qt)
        y.quant_table = uint16(qt);
    else
        y.quant_table = [];
    end
    y.eob = double(eob);

    % 放入返回结构，按 channel id 命名
    if ch_id == 1
        S.compress_image_Y = y;
    elseif ch_id == 2
        S.compress_image_CB = y;
    elseif ch_id == 3
        S.compress_image_CR = y;
    else
        % 也保存到通用数组
        field = sprintf('channel_%d', ch_id);
        S.(field) = y;
    end
end

fprintf('已从 %s 读取 %d 通道\n', filename, channel_count);
end