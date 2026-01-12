function [val, len] = rle(x)
% RLE 游程编码
%    [VAL,LEN] = RLE(X) 将向量X编码为游程值VAL和游程长度LEN
%
%    示例:
% 		>> X = [1 1 1 1 3 3 8 8 8 8 8 8]
%       >> [VAL,LEN] = RLE(X)
%    输出:
%       VAL = [1 3 8]
%       LEN = [4 2 6]

% 确保输入为行向量
if size(x, 2) == 1
    x = x.';
end

% 输入校验
if size(x, 1) ~= 1
    error('RLE只能处理向量，不能处理矩阵');
end

% 游程编码核心逻辑
diff_x = diff(x) ~= 0;
i = [find(diff_x), length(x)];
len = diff([0, i]);  % 游程长度
val = x(i);          % 游程值
end