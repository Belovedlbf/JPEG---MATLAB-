function codes = shannon_fano(P)
% SHANNON_FANO 香农-法诺编码
% 输入: P - 概率向量或频数向量
% 输出: codes - 编码字符串的元胞数组

% 检查输入参数
if nargin == 0
    error('需要输入概率或频数向量');
end

% 如果是单个元素，直接返回空编码
if length(P) == 1
    codes = {''};
    return;
end

% 确保P是行向量
P = P(:)';

% 将输入转换为双精度（避免整数运算问题）
P = double(P);

% 如果是频数，转换为概率
if sum(P) > 1
    P = P / sum(P);
end

% 初始化编码
codes = cell(1, length(P));

% 如果只有两个符号，直接分配编码
if length(P) == 2
    codes{1} = '0';
    codes{2} = '1';
    return;
end

% 按照概率降序排序
[Psorted, idx] = sort(P, 'descend');

% 找到最佳分割点
total = sum(Psorted);
sum_left = 0;
min_diff = inf;
pivot = 0;

for i = 1:length(Psorted)-1
    sum_left = sum_left + Psorted(i);
    diff = abs(2*sum_left - total);
    if diff < min_diff
        min_diff = diff;
        pivot = i;
    end
end

% 分割为左右两组
L = Psorted(1:pivot);
R = Psorted(pivot+1:end);
idxL = idx(1:pivot);
idxR = idx(pivot+1:end);

% 递归编码左右两组
codesL = shannon_fano(L);
codesR = shannon_fano(R);

% 合并编码结果
for i = 1:length(codesL)
    codes{idxL(i)} = ['0', codesL{i}];
end

for i = 1:length(codesR)
    codes{idxR(i)} = ['1', codesR{i}];
end
end