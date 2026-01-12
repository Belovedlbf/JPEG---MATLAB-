function imdisplay(immatrix)
% 通用图像显示：对整型图像（uint8/uint16）直接显示；否则按最小-最大线性缩放到 0-255 并显示
if isempty(immatrix)
    warning('空图像，无法显示。');
    return;
end

% 若输入是 uint8 或 uint16（或已经是 RGB/索引图像的常用整型），直接显示，保留原值
if isinteger(immatrix)
    imshow(immatrix);
    return;
end

% 对浮点或其他类型做线性缩放到 [0,255]
minvalue = min(immatrix(:));
maxvalue = max(immatrix(:));

if maxvalue == minvalue
    dispim = zeros(size(immatrix));
else
    dispim = 255 * (immatrix - minvalue) / (maxvalue - minvalue);
end

imshow(uint8(dispim));  % 转为uint8进行显示
end