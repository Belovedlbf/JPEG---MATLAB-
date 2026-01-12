function write_lbf(filename, varargin)
% WRITE_LBF 写入自定义 .lbf 压缩容器
% write_lbf(filename, ch1, ch2, ...)
% 每个 chN 应为 Compress 返回的结构（含 fields: r, realsize, size, numblocks, channel, quant_table(optional)）
%
% Example:
% write_lbf('out.lbf', compress_image_Y, compress_image_CB, compress_image_CR)

if nargin < 2
    error('需要至少一个通道结构体作为输入');
end

fid = fopen(filename, 'w');
if fid == -1
    error('无法打开文件写入: %s', filename);
end

cleanup = onCleanup(@() fclose(fid));

% header: magic + version + channel count
fwrite(fid, uint8('LBF'), 'uint8');      % 3 bytes magic
fwrite(fid, int32(1), 'int32');          % version = 1
channel_count = int32(nargin-1);
fwrite(fid, channel_count, 'int32');

% 写每个通道
for k = 1:channel_count
    c = varargin{k};
    % 验证必要字段
    if ~isfield(c, 'r') || ~isfield(c, 'size') || ~isfield(c, 'numblocks') || ~isfield(c, 'channel')
        error('第 %d 个结构体缺少必要字段 (r, size, numblocks, channel)', k);
    end

    % 元数据
    ch_id = int32(c.channel);
    rows = int32(double(c.size(1)));
    cols = int32(double(c.size(2)));
    numblocks = int32(double(c.numblocks));
    realsize = int32(double(c.realsize));
    % eob: 优先使用显式字段，否则用 max(r)+1 作为备选
    if isfield(c, 'eob') && ~isempty(c.eob)
        eob = int32(c.eob);
    else
        if isempty(c.r)
            eob = int32(0);
        else
            eob = int32(max(double(c.r)) + 1);
        end
    end

    % 写元数据
    fwrite(fid, ch_id, 'int32');
    fwrite(fid, rows, 'int32');
    fwrite(fid, cols, 'int32');
    fwrite(fid, numblocks, 'int32');
    fwrite(fid, realsize, 'int32');
    fwrite(fid, eob, 'int32');

    % r 向量（写长度 + 数据，数据用 int32）
    rvec = double(c.r(:))'; % 行向量
    rlen = int32(numel(rvec));
    fwrite(fid, rlen, 'int32');
    if rlen > 0
        fwrite(fid, int32(rvec), 'int32');
    end

    % 量化表（可选）
    if isfield(c, 'quant_table') && ~isempty(c.quant_table)
        fwrite(fid, uint8(1), 'uint8'); % quant_flag
        qt = uint16(reshape(double(c.quant_table), 1, [])); % 64 entries row-major
        if numel(qt) ~= 64
            error('量化表必须为 8x8');
        end
        fwrite(fid, qt, 'uint16');
    else
        fwrite(fid, uint8(0), 'uint8'); % no quant
    end

    % 可扩展：在此处可以写入更多元数据（quality/orig_filename 等）
end

fprintf('已写入 %s (%d 通道)\n', filename, channel_count);
end