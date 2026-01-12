function [ y ] = Compress( x,channel, quant_table )% flag为通道，新增 quant_table 可选参数
    if nargin < 3
        quant_table = [];
    end

    [xm, xn] = size(x);
    % z字型读取数据顺序表
    zigzag = [1 9  2  3  10 17 25 18 11 4  5  12 19 26 33  ...
            41 34 27 20 13 6  7  14 21 28 35 42 49 57 50  ...
            43 36 29 22 15 8  16 23 30 37 44 51 58 59 52  ...
            45 38 31 24 32 39 46 53 60 61 54 47 40 48 55  ...
            62 63 56 64];
        
    y = im2col(x, [8 8], 'distinct');  % 将8x8 的块转化为列
    xb = size(y, 2);                   % 分块数
    y = y(zigzag, :);                   % 按照zigzag的顺序排列数据
    
    eob = max(y(:)) + 1;               % 设置块尾结束标志
    r = zeros(numel(y) + size(y, 2), 1);
    count = 0;
    for j = 1:xb                       % 每次处理一个块
       i = max(find(y(:, j)));         % 找到最后一个非零元素
       if isempty(i)                   
          i = 0;
       end
       p = count + 1;
       q = p + i;
       r(p:q) = [y(1:i, j); eob];      % 加入块结束标志
       count = count + i + 1;          % 计数
    end
    
    r((count + 1):end) = [];           % 删除r 中不需要的元素

    [r1,r2]=size(r);%保存在一行里面
    y           = struct;%结构体
    y.realsize = r1;
    y.size      = uint16([xm xn]);
    y.numblocks = uint16(xb);
    y.r   = r;
    y.channel = channel;
    % 保存传入的量化表（如果有）
    if ~isempty(quant_table)
        y.quant_table = uint16(quant_table);
    else
        y.quant_table = [];
    end

    [value_RLC,length_RLC]=rle(r);%游程编码
    Entrophy_Code=shannon_fano(length_RLC);%熵编码采用香浓法诺编码
end