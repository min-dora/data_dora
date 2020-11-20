# 2020_1117 서울시 북촌 CCTV 데이터 분석
# environment 초기화
# rm(list = ls())
library(dplyr)
library(ggplot)
library(plotly)

# 1. 4개 구역 중 평균 진입계수가 높은 지역 알아보기


# 원본데이터 : 서울시 북촌 CCTV 유동인구 일간_주간_월간 수집 정보.csv
data.raw <- read.csv(file.choose())
data.raw %>% head()
data.raw %>% names()
data.raw %>% str()

data.group <- data.raw %>% group_by(기준날짜) %>% mutate(avg_in = mean(진입계수))
data.group.in <- data.group %>% mutate(diff_in = 진입계수-avg_in)

data.group.in %>% str()

data.group.in$설명 <- data.group.in$설명 %>% as.factor()
data.group.in$기준날짜 <- data.group.in$기준날짜 %>% as.factor()

# 4개 구역 일 평균 진입계수와 해당구역 진입계수 차이 차이 heatmap
# 0에 가까울수록 흰색, 0보다 클 수록 빨간색, 0보다 낮을수록 파란색
# 결론 : 계동교회 앞 구역에 진입하는 인구가 많고 삼청파출소 사잇길 구열에 진입하는 인구수는 적다
?scale_fill_gradient()
gp <- ggplot(data = data.group.in, aes(x = 기준날짜, y = 설명, fill = diff_in))+
  geom_raster()+
  scale_fill_gradient2(low = "blue", high = "red", midpoint = 0, mid = "white")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # x축 label 회전

ggplotly(gp)

# 2. 요일별 가장 진출입이 많은 요일은? (유동인구가 가장 많은 요일?)
data.raw %>% str()
data.use <- data.raw
# 기준날짜 변수를 Date타입으로 변환하기
data.use$date<- data.use$기준날짜 %>% as.character() %>% as.Date(origin = "1900-01-01", format = "%Y%m%d")
data.use

# 요일 변수 만들기
data.use$weekday <- format(data.use$date, format = "%A")
data.use$weekday %>% head()

data.use %>% str()

# 요일 변수 factor화 시키기
data.use$weekday <- data.use$weekday %>% factor(levels = c("월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"))
data.use %>% str()

#
df1 <- data.use %>% group_by(weekday) %>% summarise(avg_in = mean(진입계수))

df1

ggplot(data = df1, aes(x = weekday, y = avg_in))+geom_bar(stat = "identity")+
  coord_cartesian(ylim = c(9000,10200))

# ?geom_bar()
# ?theme()

#2020_1120











