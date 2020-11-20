# 2020_1116 제주도 기상정보 분석
rm(list = ls())

# library
library(dplyr)
library(ggplot2)
library(plotly)

# 데이터 : 제주특별자치도개발공사_기상 정보_20191231.csv
data.raw <- read.csv(file.choose())
data.raw %>% head()
data.raw %>% dim()
data.raw %>% str()

# 변수명 변경
names(data.raw) <- c("일자", "평균기온", "최대기온", "최소기온", "평균지표온도", "최대지표온도", "최소지표온도", "습도", "일사량", "풍속")
data.raw

# 1. 일교차 가장 심한 날짜 뽑기(일병 or 월 평균 일교차) & 시계열 그래프
# 2. 불쾌지수 분석

### 2020_1117 수정

# 일교차 변수 만들기 (최대기온-최소기온)
data.tempdist <- mutate(data.raw, temp_dist = 최대기온-최소기온)
data.tempdist %>% head()

arrange(data.tempdist, desc(temp_dist))

ggplot(data = data.tempdist)+geom_line(aes(x = 일자, y = temp_dist), group = 1)

data.month <- mutate(data.tempdist, 월 = substr(data.tempdist$일자, 6,7))

# 월별 평균 일교차

data.gr <- group_by(data.month, 월)

summarise(data.gr, avg = mean(temp_dist))

data.avg.td <- mutate(data.gr, temp_dist_avg = mean(temp_dist))

# 봄, 가을에 일교차가 큰 것을 볼 수 있음.
gp <- ggplot(data = data.avg.td)+geom_line(aes(x = 월, y = temp_dist_avg), group = 1, size = 2)+geom_point(aes(x = 월, y = temp_dist_avg), size = 3, colour = "red")
ggplotly(gp)

# 불쾌지수 변수 만들기 (Temperature Humidity Index =  '1.8 × 온도 - 0.55 (1 - 습도) (1.8 × 온도 - 26) + 32' )
# 습도가 퍼센트 이므로 소수로 바꿔주기 => (습도/100)
data.thi <-mutate(data.month, THI = 1.8*평균기온-0.55*(1-습도/100)*(1.8*평균기온-26)+32)

# 불쾌지수 단계 변수 만들기
data.thi$THI_level <- 
  ifelse(data.thi$THI>=80, "매우높음", 
       ifelse(data.thi$THI>=75 & data.thi$THI<80, "높음", 
              ifelse(data.thi$THI>=68 & data.thi$THI<75, "보통", "낮음")))

# 불쾌지수 단계가 매우 높음인 날 골라보기
subset(data.thi, THI_level=="매우높음")

# 불쾌지수 최빈값 구하기 (R은 최빈값을 구하는 함수가 내장되어 있지 않음)
y <- table(data.thi$THI_level)
names(y)[which(y == max(y))]

# group_by된 데이터에 달 별 불쾌지수 최빈값 변수 추가
data.thi.gr <- group_by(data.thi, 월)

summarise(data.thi.gr, THI_level_count = names(table(THI_level))[which(table(THI_level)==max(table(THI_level)))])

data.thi.group <- mutate(data.thi.gr, THI_level_count = names(table(THI_level))[which(table(THI_level)==max(table(THI_level)))])

# 변수 타입 확인
str(data.thi.group)

# THI_level_count 변수를 팩터로 변경 및 level설정
data.thi.group$THI_level_count <- factor(data.thi.group$THI_level_count, levels = c("낮음","보통","높음","매우높음"))
str(data.thi.group)

# ggplot
ggplot(data = data.thi.group)+geom_line(aes(x = 월, y = THI_level_count), group = 1)+
  geom_point(aes(x = 월, y = THI_level_count), size = 3)





# 1.8*data.month$평균기온-0.55*(1-data.month$습도/100)*(1.8*data.month$평균기온-26)+32
