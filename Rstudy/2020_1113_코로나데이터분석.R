# 2020_1113 교수님 프로젝트
# 코로나 데이터, 유동인구 데이터, 기상 데이터 수집


# 서울시 코로나19 확진자 현황 (csv or 오픈 api 둘 다 가능!)

# http://data.seoul.go.kr/dataList/OA-20279/S/1/datasetView.do

## 학습목표 -> 
# 1. 구 마다 어느 지역이 가장 많이 확진자가 나온지
# 2. 월별 확진자 수 시계열 그래프
# 3. 여행력별로 어느 지역에서 많이 확진자가 여행을 많이 다녀온지 (해당 나라 방문시 주의의 정도를 비교할 수 있음.)
# 4. 접촉력이 가장 강한지역 빈도분석 (심화하면 해당 지역 google에 좌표 검색해서 지도에 맵 띄우기)

# library
library(dplyr)
library(ggplot2)
library(plotly)



# 서울시 코로나19 확진자 현황.csv 불러오기
data.raw <- read.csv(file.choose())
View(data.raw)
head(data.raw)
dim(data.raw)

### 1. 구 마다 어느 지역이 가장 많이 확진자가 나온지

## 전체 기간 동안 각 구 별로 확진자 수 비교

# (table화 후 데이터프레임으로 변경)
data.table <- data.raw$지역 %>% table() %>% as.data.frame()

# 변수명 변경
names(data.table) <- c("구", "확진자수")

# 데이터 정렬 (dplyr 패키지의 arrange 함수 이용)
arrange(data.table, 확진자수)
arrange(data.table, desc(확진자수))
?arrange
# 그래프 그리기
ggplot(data = data.raw)+ geom_bar(aes(x = 지역))+
  coord_flip()
ggplot(data = data.table)+ geom_bar(aes(x = 구, 확진자수), stat = "identity")+
  coord_flip()

## 정렬데이터로 그래프

# 내림차순 그래프 (그래프에선 reorder 함수를 통해 정렬)
gp <- ggplot(data = data.table, aes(x = reorder(구, 확진자수), y = 확진자수))+ geom_col()+
  coord_flip()
# plotly패키지의 ggplotly 함수를 통해 대화형 그래프
ggplotly(gp)

# 오름차순 그래프 (그래프에선 reorder 함수를 통해 정렬, -부호를 붙혀서 반대로)
gp2 <- ggplot(data = data.table, aes(x = reorder(구, -확진자수), y = 확진자수))+ geom_col()+
  coord_flip()

# plotly패키지의 ggplotly 함수를 통해 대화형 그래프
ggplotly(gp2)

### 2. 월별로 확진자수 시계열 그래프

# 원본데이터 복사하기
data.date <- data.raw
# 확진일 자료형 확인
data.raw$확진일 %>% str()

# 자료형 date타입으로 변경
data.date$확진일 <- data.raw$확진일 %>% as.Date("%m.%d")
data.date %>% str()

# 월별로만 나누기 (substr함수로 월만 긁어온 뒤 factor화)
data.date$확진월 <- substr(data.date$확진일, 6,7) %>% as.factor()
data.date$확진월 %>% str()

?group_by()

# groupby함수로 월별 확진자수 확인
data.group <- group_by(data.date, 확진월) %>% summarise(n = n())

# 월별 확진자 시계열 그래프 그리기
gp.line <- ggplot(data = data.group, aes(x = 확진월, y = n, group = 1))+
  geom_line(size = 2, color = "red")+
  geom_point(size = 3)+
  ggtitle("월별 확진자수 시계열그래프")
gp.line

# plotly로 대화형 그래프
ggplotly(gp.line)


#### 2020_1114 추가
###### 거주지가 아닌 접촉력 위험지역 분석

### 데이터 탐색 및 전처리

# 접촉력 종류 확인 (unique 함수)
data.raw$접촉력 %>% unique()

# 접촉력 빈도 분석 
data.tb <- data.raw$접촉력 %>% table() %>% tail()

# 데이터프레임화
data.df <- data.tb %>% as.data.frame()

# 변수명 변경
names(data.df) <- c("접촉력", "빈도")

# 접촉력 상위 요인 10개 확인 (성북구 교회, 해외접촉, 이태원 클럽, 8.15도심집회, 리치웨이, 도봉구)
data.df %>% arrange(desc(빈도)) %>% head(10)

### 여행력에 따른 위험국가 및 확진자 발생 기간 분석
## 전처리 및 분석



# 여행력 범주 확인
data.raw$여행력 %>% table()

# 여행력이 있는 데이터 선정
data.world <- data.raw %>% subset(여행력!='')

# 그룹화
data.world.group <- data.world %>% group_by(여행력)

# 그룹화 된 데이터를 count한 후 내림차순 정렬 상위 5개국
data.world.count5 <- data.world.group %>% summarise(count = n()) %>% arrange(desc(count)) %>% head()

# 전체 여행력 그래프 
ggplot(data = data.world)+geom_bar(aes(x = 여행력, y = ''), stat = "identity")+coord_flip()

# 여행력 상위 5개국 => 최다 여행력 국가 = 미국
ggplot(data = data.world.count5)+geom_col(aes(reorder(여행력, count), y = count))+coord_flip()

# 그럼 미국을 방문 했던 사람들이 많이 확진받은 날은?
data.usa <- subset(data.date, data.date$여행력=="미국")

# 그룹화+count+내림차순 (주로 3월 말에서 4월 초 넘어가는 시기에 가장 많이 발생! 3월에ㄴ서 4월 사이에 미국을 방문한 사람은 코로나 위험성 높음!)
data.usa %>% group_by(확진일) %>% summarise(count = n()) %>% arrange(desc(count))

# 2020_1120




















