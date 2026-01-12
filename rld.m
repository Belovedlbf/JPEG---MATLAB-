function [x] = rld(val, len)
% RLD 游程解码
%    X = RLD(VAL,LEN) 将游程值VAL和游程长度LEN解码为向量X
%
%    示例:
%       >> VAL = [1 3 8]
%       >> LEN = [4 2 6]
%       >> X = RLD(VAL,LEN)
%    输出:
%       X = [1 1 1 1 3 3 8 8 8 8 8 8]

% 输入校验
if ~isvector(len) || ~isvector(val)
    error('len和val必须是向量');
end
if length(len) ~= length(val)
    error('len和val必须长度相同');
end

% 确保len为行向量
if size(len, 2) == 1
    len = len.';
end

% 游程解码核心逻辑
x = [];
for i = 1:length(val)
    x = [x, repmat(val(i), 1, len(i))];
end
end