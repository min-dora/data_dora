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
  geom_hex(aes(x = 경도, y = 위도), bins = 18, alpha = 0.5, data = data.gr)

gm <- gm+scale_fill_gradientn(colours = colorRampPalette(c("white", "darkred"))(5))

# add point
gm_hex <- gm+geom_point(data = data.gr, aes(x = 경도, y = 위도, colour = 발생지시군구), size = 3, alpha = 0.5)+
  theme(panel.grid.major.x = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank())+
  labs(title = "대전광역시 교통사고_사망 지역")

# ggplotly
gm_hex %>% ggplotly()



# 서구 가해자 피해자 교차테이블
data.west <- data.gr %>% filter(발생지시군구=='서구')
table(data.west$가해자_당사자종별, data.west$피해자_당사자종별)ㄴ
table(data.gr$가해자_당사자종별, data.gr$피해자_당사자종별)
