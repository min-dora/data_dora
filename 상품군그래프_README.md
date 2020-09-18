# #상품군_README
## ## encoding by. utf-8

## # 기초환경설치

### package설치(dplyr, reshape2, ggplot2, scales)

```c
install.packages("dplyr")

install.packages("reshape2")

install.packages("ggplot2")

install.packages("scales")
```

### library불러오기

```c
library(dplyr)  

library(reshape2)

library(ggplot2)

library(scales)	
```
---------------------------------------------
---------------------------------------------
---------------------------------------------
##### 변수 초기화
```c
rm(list=ls())
```

## 데이터 불러오기
+ 파일명 : "온라인쇼핑몰_취급상품범위_상품군별거래액_20200831163311.csv"

```c
data.use <- read.csv(choose.files(),)

data.use %>% head()
```

# # 분기 별 온라인 쇼핑 합계액

## 데이터 전처리

### 사용 데이터 추출
+ data.use에서 `시점`과`합계`열을 선택해서 data.use.1

```c
data.use.1 <- data.use %>% dplyr::select(시점,합계)
data.use.1 %>% head()
```

### 컬럼명 변경
+ data.use.1의 변수명을 `분기`,`(억)원`으로 변경

```c
names(data.use.1) <- c("분기","(억)원")
```

## 데이터 시각화
+ data.use.1의 `분기`를 이용한 x축,`(억)원`을 이용한 y축을 가진 ggplot생성 
+ 크기는2, 색은 skyblue를 가진 꺽은선 그래프를 그리기
+ y축 레이블에 콤마를 찍어주는 역할
+ 그래프의 레이블 글씨 크기는 30 축제목은 25와 글씨굵기를 진하게 지정하고 x축의 레이블 각도를 45도로 지정

```c
ggp <- ggplot(data=data.use.1,aes(x=분기,y=`(억)원`,group=1)) +
  geom_line(size=2,color="skyblue")+
  scale_y_continuous(labels=comma) +
  theme(axis.text=element_text(size=30),axis.title=element_text(size=25,face="bold"),axis.text.x=element_text(angle=45,hjust=1)) 
  
ggp 	
```



# # 분기 별 온라인쇼핑 상품군 거래액

## 데이터 전처리

### 사용 데이터 추출
+ data.use에서 `시점`,`가전.전자.통신기기`,`생활용품`,`음식서비스`,`여행.및.교통서비스`,`음.식료품` 열을 추출하여 data.use.2에 저장

```c
data.use.2 <- data.use %>% dplyr::select(시점,가전.전자.통신기기,생활용품,음식서비스,여행.및.교통서비스,음.식료품)
data.use.2 %>% head()
```

### 컬럼명 변경
+ data.use.2의 변수명을 "시점","가전전자통신기기","생활용품","배달음식서비스","여행및교통서비스","음식료품" 로 변경

```c
names(data.use.2) <- c("시점","가전전자통신기기","생활용품","배달음식서비스","여행및교통서비스","음식료품")
```

## 데이터 재구조화
+ melt()를 이용해 재구조화하여 "data.melt.2"에 저장
+ 식별자변수 = "시점"     
+ 측정변수 = "가전전자통신기기","생활용품","배달음식서비스","여행및교통서비스","음식료품"

```c
data.melt.2 <- melt(data.use.2,id.var="시점",measure.vars=c("가전전자통신기기","생활용품","배달음식서비스","여행및교통서비스","음식료품"))
```

### 컬럼명 변경
+ 재구조화시킨 data.melt.2의 변수명을 "분기","상품군","(억)원"로 변경

```c
names(data.melt.2) <- c("분기","상품군","(억)원")
data.melt.2 %>% summary()
data.melt.2 %>% head()
```

## 데이터 전처리

### 가전전자통신기기
+ data.melt.2의 `상품군`열에 `가전전자통신기기`가 들어있는 행만 추출하여 data.melt.a에 저장
+ data.melt.a의 1행3열에 해당하는 2017년1분기 거래액을 기준으로 각 분기를 나눈 값에 100을 곱한 후 data.melt.a의 prepro열을 생성하고 저장

```c
data.melt.a <- data.melt.2 %>% filter(상품군=='가전전자통신기기')
data.melt.a$prepro <- data.melt.a$`(억)원`/data.melt.a[1,3]*100
```

### 생활용품
+ data.melt.2의 `상품군`열에 `생활용품`이 들어있는 행만 추출하여 data.melt.b에 저장
+ data.melt.b의 1행3열에 해당하는 2017년1분기 거래액을 기준으로 각 분기를 나눈 값에 100을 곱한 후 data.melt.b의 prepro열을 생성하고 저장

```c
data.melt.b <- data.melt.2 %>% filter(상품군=='생활용품')
data.melt.b$prepro <- data.melt.b$`(억)원`/data.melt.b[1,3]*100
```

### 배달음식서비스
+ data.melt.2의 `상품군`열에 `배달음식서비스`가 들어있는 행만 추출하여 data.melt.c에 저장
+ data.melt.c의 1행3열에 해당하는 2017년1분기 거래액을 기준으로 각 분기를 나눈 값에 100을 곱한 후 data.melt.c의 prepro열을 생성하고 저장

```c
data.melt.c <- data.melt.2 %>% filter(상품군=='배달음식서비스')
data.melt.c$prepro <- data.melt.c$`(억)원`/data.melt.c[1,3]*100
```

### 여행및교통서비스
+ data.melt.2의 `상품군`열에 `여행및교통서비스`가 들어있는 행만 추출하여 data.melt.d에 저장
+ data.melt.d의 1행3열에 해당하는 2017년1분기 거래액을 기준으로 각 분기를 나눈 값에 100을 곱한 후 data.melt.d의 prepro열을 생성하고 저장

```c
data.melt.d <- data.melt.2 %>% filter(상품군=='여행및교통서비스')
data.melt.d$prepro <- data.melt.d$`(억)원`/data.melt.d[1,3]*100
```

### 음식료품
+ data.melt.2의 `상품군`열에 `음식료품`이 들어있는 행만 추출하여 data.melt.e에 저장
+ data.melt.e의 1행3열에 해당하는 2017년1분기 거래액을 기준으로 각 분기를 나눈 값에 100을 곱한 후 data.melt.e의 prepro열을 생성하고 저장

```c
data.melt.e <- data.melt.2 %>% filter(상품군=='음식료품')
data.melt.e$prepro <- data.melt.e$`(억)원`/data.melt.e[1,3]*100
```

### 최종데이터 
+ 전처리시킨 데이터 `data.melt.a`,`data.melt.b`,`data.melt.c`,`data.melt.d`,`data.melt.e`를 rbind함수를 이용해서 밑으로 병합

```c
data.rb <- rbind(data.melt.a,data.melt.b,data.melt.c,data.melt.d,data.melt.e)
data.rb %>% tail()
```

## 데이터 시각화 ##
+ data.rb의 `분기`를 이용해 x축을,`prepro`를 이용해 y축을 그룹과 색을 `상품군`으로 나눈 ggplot을 그리기
+ x축제목은 "분기",y축제목을"변화율(%)"로 하는 꺽은선 그래프를 그리기
+ y축의 레이블 범위를 100,300,500,700으로 지정
+ 그래프의 레이블 크기를 25크기로, 축제목의 크기를 25와 굵기를 진하게 지정하고 x축 레이블의 각도를 45로 지정
+ 범례의 제목을 25크기와 굵기를 진하게 지정, 범례글씨는 20크기로 지정

```c
ggp <- ggplot(data=data.rb,aes(x=분기,y=`prepro`,group=상품군,color=상품군)) +
  geom_line(size=2) + labs(x="분기", y="변화율(%)") +
  scale_y_continuous(breaks=c(100,300,500,700)) +
  theme(axis.text=element_text(size=25),axis.title=element_text(size=25,face="bold"),axis.text.x=element_text(angle=45,hjust=1)) +
  theme(legend.title=element_text(size=25,face="bold"),legend.text=element_text(size=20))
  
ggp
```
