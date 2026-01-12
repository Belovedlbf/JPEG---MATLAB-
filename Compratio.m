%计算压缩率
%压缩大小在原图大小和计算机处理的JPEG格式压缩大小之间
function comp_ratio = Compratio(orig_image, comp_image)

%计算有多少比特应该被用来替代原图像保存在B0变量中
clear tempmatr1; 
tempmatr1 = ceil(log2(orig_image+1));
clear sizevector1;
sizevector1 = size(orig_image);
[rownum, colnum] = size(sizevector1);
while colnum >1
    clear tempmatr2;
    tempmatr2 = sum(tempmatr1);
    clear tempmatr1;
    tempmatr1 = tempmatr2;
    colnum = colnum -1;
end
B0 = sum(tempmatr1);

%计算有多少比特应该被用来替代压缩之后的图像保存在B1变量中
clear tempvec1;
tempvec1 = find(comp_image<0);
clear tempmatr1;
if sum(tempvec1) == 0
    tempmatr1 = ceil(log2(comp_image+1));
else
    tempmatr1 = ceil(log2(abs(comp_image)+1))+1;
end
clear sizevector1;
sizevector1 = size(comp_image);
[rownum, colnum] = size(sizevector1);
while colnum >1
    clear tempmatr2;
    tempmatr2 = sum(tempmatr1);
    clear tempmatr1;
    tempmatr1 = tempmatr2;
    colnum = colnum -1;
end
B1 = sum(tempmatr1);
comp_ratio = B0/B1;
