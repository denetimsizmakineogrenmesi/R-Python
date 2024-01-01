#data komutu ile cikan listede iris verisetini gorebiliriz
data()


#use the iris dataset
#for more info type Iris
names(iris)
[1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species"

head(iris)
Sepal.Length Sepal.Width Petal.Length Petal.Width Species
1          5.1         3.5          1.4         0.2  setosa
2          4.9         3.0          1.4         0.2  setosa
3          4.7         3.2          1.3         0.2  setosa
4          4.6         3.1          1.5         0.2  setosa
5          5.0         3.6          1.4         0.2  setosa
6          5.4         3.9          1.7         0.4  setosa

#perform hierarchical clustering
h <- hclust(dist(iris[,c(1:4)]))

#inside the h object
names(h)
[1] "merge"       "height"      "order"       "labels"      "method"      "call"      
[7] "dist.method"

#order corresponds to the hierarchical clustering order on iris rows
h$order
[1] 108 131 103 126 130 119 106 123 118 132 110 136 141 145 125 121 144 101 137 149 116 111 148 113 140
[26] 142 146 109 104 117 138 105 129 133 150  71 128 139 115 122 114 102 143 135 112 147 124 127  73  84
[51] 134 120  69  88  66  76  77  55  59  78  87  51  53  86  52  57  75  98  74  79  64  92  61  99  58
[76]  94 107  67  85  56  91  62  72  68  83  93  95 100  89  96  97  63  65  80  60  54  90  70  81  82
[101]  42  30  31  26  10  35  13   2  46  36   5  38  28  29  41   1  18  50   8  40  23   7  43   3   4
[126]  48  14   9  39  17  33  34  15  16   6  19  21  32  37  11  49  45  47  20  22  44  24  27  12  25

#order dataset by hierarchical clustering
data_ordered <- iris[h$order,]

head(data_ordered)
Sepal.Length Sepal.Width Petal.Length Petal.Width   Species
108          7.3         2.9          6.3         1.8 virginica
131          7.4         2.8          6.1         1.9 virginica
103          7.1         3.0          5.9         2.1 virginica
126          7.2         3.2          6.0         1.8 virginica
130          7.2         3.0          5.8         1.6 virginica
119          7.7         2.6          6.9         2.3 virginica

#perform the SVD
svd1 <- svd(data_ordered[,c(1:4)])

#inside the svd1 object are the 3 separate matrices
names(svd1)
[1] "d" "u" "v"

#left singular vectors corresponding to the rows
dim(svd1$u)
[1] 150   4

#right singular vectors corresponding to the columns
dim(svd1$v)
[1] 4 4

#singular vectors
svd1$d
[1] 95.959914 17.761034  3.460931  1.884826

head(svd1$u)
[,1]       [,2]        [,3]         [,4]
[1,] -0.1054558 0.08012812 -0.10637239 -0.134454550
[2,] -0.1049482 0.07556145 -0.12829465 -0.009698646
[3,] -0.1026729 0.07009470 -0.01813207  0.036368121
[4,] -0.1042575 0.06052312 -0.03846043 -0.125453575
[5,] -0.1020462 0.05482986 -0.11193348 -0.120558750
[6,] -0.1114810 0.11657800 -0.13510080  0.030542780

#plot all left singular vectors
par(mfrow=c(1,4))
plot(svd1$u[,1],1:150,pch=19)
plot(svd1$u[,2],1:150,pch=19)
plot(svd1$u[,3],1:150,pch=19)
plot(svd1$u[,4],1:150,pch=19)
#reset graphical parameter
par(mfrow=c(1,1))
