function [x] = Decompress(y)
    % 亮度量化矩阵（基准）
    Luminance = [
        16 11 10 16 24 40 51 61;  
        12 12 14 19 26 58 60 55;  
        14 13 16 24 40 57 69 55;  
        14 17 22 29 51 87 80 62;  
        18 22 37 56 68 109 103 77;  
        24 35 55 64 81 104 113 92;  
        49 64 78 87 103 121 120 101;  
        72 92 95 98 112 100 103 99;
    ];  

    % 色度量化矩阵（基准）
    Chrominance = [
        17 18 24 47 99 99 99 99;  
        18 21 26 66 99 99 99 99;  
        24 26 56 99 99 99 99 99;  
        47 66 99 99 99 99 99 99;  
        99 99 99 99 99 99 99 99;  
        99 99 99 99 99 99 99 99;  
        99 99 99 99 99 99 99 99;  
        99 99 99 99 99 99 99 99;
    ]; 
     
    % 之字形扫描顺序
    zigzag = [1 9  2  3  10 17 25 18 11 4  5  12 19 26 33  ...
            41 34 27 20 13 6  7  14 21 28 35 42 49 57 50  ...
            43 36 29 22 15 8  16 23 30 37 44 51 58 59 52  ...
            45 38 31 24 32 39 46 53 60 61 54 47 40 48 55  ...
            62 63 56 64];
    
    % 逆之字形映射
    rev = zeros(size(zigzag));
    for k = 1:length(zigzag)
       rev(k) = find(zigzag == k);
    end
    
    % 从结构体中读取元数据
    sz = double(y.size);
    xn = sz(2);                  % 列数
    xm = sz(1);                  % 行数
    x_stream = y.r(:)';          % 压缩后数据，确保为行向量

    if isempty(x_stream)
        error('压缩数据为空，无法解压。');
    end

    eob = max(x_stream);         % 块结束标记（在 Compress 中为 max(block)+1）

    % 优先通过流中 eob 的数量来确定块数（更可靠）
    xb_from_stream = sum(x_stream == eob);
    expected_blocks = (xm/8) * (xn/8);

    if xb_from_stream > 0
        xb = xb_from_stream;
    else
        % 回退到结构体记录的 numblocks（兼容旧数据/异常情况）
        xb = double(y.numblocks);
    end

    % 解析流，按 eob 分块，填充到 64 行
    z = zeros(64, xb);   
    k = 1;
    n = length(x_stream);
    for j = 1:xb
       i = 0;
       while k <= n && x_stream(k) ~= eob && i < 64
          i = i + 1;
          z(i, j) = x_stream(k);
          k = k + 1;
       end
       % 跳过当前的 eob 标志（如果存在）
       if k <= n && x_stream(k) == eob
          k = k + 1;
       end
    end

    % 补齐或裁剪块数，保证 col2im 能工作
    if xb < expected_blocks
        z(:, end+1:expected_blocks) = 0;
        xb = expected_blocks;
        warning('解析到的块数小于期望块数，已用零块补齐。');
    elseif xb > expected_blocks
        z = z(:, 1:expected_blocks);
        xb = expected_blocks;
        warning('解析到的块数大于期望块数，已裁剪多余块。');
    end
    
    % 逆之字形排列
    z = z(rev, :);                                 
    
    % 恢复图像块
    x = col2im(z, [8 8], [xm xn], 'distinct');     
    
    % 反量化：优先使用压缩结构里保存的量化表（如果存在），否则用基准表
    if isfield(y, 'quant_table') && ~isempty(y.quant_table)
        qt = double(y.quant_table);
    else
        if y.channel == 1
            qt = Luminance;
        else
            qt = Chrominance;
        end
    end

    if y.channel == 1
        quant_fun = @(block_struct) block_struct.data .* qt;
    else
        quant_fun = @(block_struct) block_struct.data .* qt;
    end
    x = blockproc(x, [8 8], quant_fun);
    
    % 逆DCT变换
    T = dctmtx(8);
    idct_fun = @(block_struct) T' * block_struct.data * T;
    x = blockproc(x, [8 8], idct_fun);
end