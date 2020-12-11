# 2020_1129 도로교통공단_사망 교통사고정보_20201123.csv
# rm(list = ls())
library(dplyr)
library(ggplot2)
library(ggmap)
library(plotly)
library(RColorBrewer)

data.raw <- read.csv(file.choose())
data.raw %>% head()
data.raw %>% names()


# 대전 데이터 뽑아오기
data.daejeon <- subset(data.raw, 발생지시도=="대전")

# 구별 그룹 + 사고건수 확인
data.gr <- group_by(data.daejeon, 발생지시군구) %>% mutate(count = n())
data.gr %>% str()

data.gr$발생지시군구 <- data.gr$발생지시군구 %>% factor()

ggplot(data = data.gr)+geom_bar(aes(x = 발생지시군구, fill = 발생지시군구))
# 서구에서 가장 많이 일어난 것을 볼 수 있음.


# 경도 위도 상자 좌표 계산 함수
fn_lon_lat_box <- function(lon, lat, dist = 1){
  h <- 0.0035*3.5*dist
  w <- 0.0035*4*dist
  # 경위도 표시할 사각형의 좌하 우상의 좌표
  c(lon-w, lat-h, lon+w, lat+h)
}
# 대전시청 좌표
# 36.339903, 127.394984
# boxlocation <- fn_lon_lat_box(127.394984, 36.339903, 6)
# djmap <- get_map(boxlocation)

# 구글키 삽입 (github 업로드로 인해 #처리, 실제로는 본인 키 넣음)
# register_google(key='#############################')
###
### 2020.12.04 기준 google cloud platform 무료판 종료로 stateman이용
###

# 중심좌표
boxlocation <- fn_lon_lat_box(127.378953, 36.321655, 8)

djmap <- get_map(boxlocation)

# 지도 확인
ggmap(djmap)

# 지도에 점 추가
gp <- ggmap(djmap)+geom_point(data = data.gr, aes(x = 경도, y = 위도,fill = 발생지시군구), size = 3, alpha = 0.5)

# 대화형 지도
ggplotly(gp)


# add hexgon
gm <- ggmap(djmap)+coord_cartesian()+
  geom_hex(aes(x = 경도, y = 위도), bins = 11, alpha = 0.5, data = data.gr)

gm <- gm+scale_fill_gradientn(colours = colorRampPalette(c("white", "darkred"))(5))

# add point
gm_hex <- gm+geom_point(data = data.gr, aes(x = 경도, y = 위도, colour = 발생지시군구), size = 4, alpha = 0.5)+
  theme(panel.grid.major.x = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(),
        axis.text = element_blank(), axis.title = element_blank(), axis.line = element_blank())+
  labs(title = "대전광역시 교통사고_사망 지역")+
  theme(legend.justification = "top")

gm_hex

?theme
# ggplotly
gm_hex %>% ggplotly()



# 서구 가해자 피해자 교차테이블
data.west <- data.gr %>% filter(발생지시군구=='서구')

table(data.west$가해자_당사자종별, data.west$피해자_당사자종별)
table(data.gr$가해자_당사자종별, data.gr$피해자_당사자종별)

data.gr$가해자_당사자종별 %>% table
data.gr$피해자_당사자종별 %>% table

a1 <- ggplot(data = data.gr)+geom_bar(aes(x = 발생지시군구, y = '', fill = 가해자_당사자종별), stat = "identity")
a1 <- ggplot(data = data.gr)+geom_bar(aes(x = 발생지시군구, y = '', fill = 가해자_당사자종별), stat = "identity", position = "fill")
ggplotly(a1)

a2 <- ggplot(data = data.gr)+geom_bar(aes(x = 발생지시군구, y = '', fill = 피해자_당사자종별), stat = "identity")
a2 <- ggplot(data = data.gr)+geom_bar(aes(x = 발생지시군구, y = '', fill = 피해자_당사자종별), stat = "identity", position = "fill")
ggplotly(a2)


data.gr$요일 <- data.gr$요일 %>% factor(levels = c("월", "화","수", "목", "금", "토", "일"))
data.gr %>% str()
data.gr$요일 %>% table()

ggplot(data = data.gr)+geom_bar(aes(x = 요일, y = '', fill = 주야), stat = "identity")+
  coord_cartesian(ylim=c(1, 15))

#ggplot(data = data.gr)+geom_bar(aes(x = 가해자_당사자종별, y = '', fill = 요일), stat = "identity")+
#  coord_cartesian(ylim=c(1, 50))

names(data.gr)

# 사고시간 변수 추가
data.daejeon$hour <- (data.daejeon$발생년월일시 %>% substr(12,13)) %>% as.factor()
data.daejeon %>% str()

data.daejeon$hour %>% table() %>% barplot(, main = "시간대별 사고건수", xlab = "시간", ylab = "사고건수", lwd = 3)

# 시간대별 사고건수
data.daejeon.summ <- data.daejeon %>% group_by(hour) %>% mutate(count_h = n())
ggplot(data.daejeon.summ, aes(x = hour, fill = count_h))+
  geom_bar()+
  ggtitle("# 시간대별 사고건수")+
  theme(title = element_text(size = 15))+
  scale_fill_gradient(low = "green", high = "red")

scale_fill_identity()
?element

ggplot(data = data.daejeon)+geom_line(aes(x = hour, group = 1), stat = "count")+geom_point(aes(x = hour, group = 1), stat = "count")

ggplot(data = data.daejeon)+
  geom_bar(aes(x = hour), stat = "count", fill = group.summ$acident_count)+
  scale_fill_brewer(palette = "Greens")+
  geom_line(aes(x = hour, group = 1), stat = "count")+
  geom_point(aes(x = hour, group = 1), stat = "count", colour = "red") # 시간대 별 사고 건수 barplot

data.daejeon.gr.hour <- group_by(data.daejeon, hour) %>% mutate(acident_count = n())
(data.daejeon$hour)

data.daejeon.gr.hour$acident_count
group.summ<- group_by(data.daejeon, hour) %>% summarise(acident_count = n())
?geom_bar()
group.summ[2] %>% as.vector()

group.summ[2] %>% str()

scale_fill_brewer(palette = "Greens")










