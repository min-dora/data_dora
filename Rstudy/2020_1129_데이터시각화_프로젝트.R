# 2020_1129 도로교통공단_사망 교통사고정보_20201123.csv
library(dplyr)
library(ggplot2)
library(ggmap)
library(plotly)

data.raw <- read.csv(file.choose())
data.raw %>% head()
data.raw %>% names()


# 대전 데이터 뽑아오기
data.daejeon <- subset(data.raw, 발생지시도=="대전")

# 구별 그룹 + 사고건수 확인
data.gr <- group_by(data.daejeon, 발생지시군구) %>% mutate(count = n())
data.gr %>% str()

data.gr$발생지시군구 <- data.gr$발생지시군구 %>% factor()

ggplot(data = data.gr)+geom_bar(aes(x = 발생지시군구))


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
register_google(key='#############################')

# 중심좌표 (google api키 사용)
boxlocation <- c(127.378953, 36.321655)
djmap <- get_map(boxlocation, maptype="roadmap",source="google",zoom=12)
djmap

# 지도 확인
ggmap(djmap)

# 지도에 점 추가
gp <- ggmap(djmap)+geom_point(data = data.gr, aes(x = 경도, y = 위도,fill = 발생지시군구), size = 3, alpha = 0.5)

# 대화형 지도
ggplotly(gp)

