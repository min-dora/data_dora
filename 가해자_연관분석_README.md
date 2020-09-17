# randomforest_README

## #기초환경설치
### package설치 (caret, dplyr, randomForest, ggplot2)

```c 

install.packages("dplyr")
    
install.packages("arules")
    
install.packages("arulesViz")
    
install.packages("RColorBrewer")
```

### library 불러오기

```c
library(dplyr)

library(arules)

library(arulesViz)

library(RColorBrewer)
```
---------------------------------------------
---------------------------------------------
---------------------------------------------

## #기초 전처리

### 원본데이터 불러오기

+ 코드를 실행하여 첨부한 원본데이터 (가해자차종 또는 피해자차종이 이륜차인 교통사고 정보(2015~2019년).csv)를 불러옵니다.

```c
data <- read.csv(file.choose())
```


### 필요한 변수 선택

+ select()를 통해 원본데이터에서 사용할 변수들만 뽑음

```c
data.use <- select(data, 요일, 가해자법규위반, 노면상태, 기상상태, 가해당사자종별, 가해자신체상해정도, 가해자보호장구, 피해당사자종별, 피해자신체상해정도, 피해자보호장구)
```

### 신체상해정도(중상, 경상, 부상신고)를 부상으로 바꿔주기 => (사망, 부상, 상해없음)

+ ifelse()를 통해 신체상해정도가 "중상, 경상, 부상신고"인 것들을 부상으로 바꾸고, 사망과 상해없음은 그대로 불러오기

```c
data.use$가해자신체상해정도 <- ifelse(data.use$가해자신체상해정도=="중상"|data.use$가해자신체상해정도=="경상"|data.use$가해자신체상해정도=="부상신고", "부상", data.use$가해자신체상해정도)
data.use$가해자신체상해정도 %>% table()

data.use$피해자신체상해정도 <- ifelse(data.use$피해자신체상해정도=="중상"|data.use$피해자신체상해정도=="경상"|data.use$피해자신체상해정도=="부상신고", "부상", data.use$피해자신체상해정도)
data.use$피해자신체상해정도 %>% table()
```

### 신체상해정도가 "기타불명"인 경우를 제외

+ 신체상해정도가 "기타불명" => 어느정도 다쳤는지 알 수 없기 때문에 filter함수를 통해 분석에서 제거

```c
data.use <- filter(data.use, data.use$가해자신체상해정도!="기타불명"&data.use$피해자신체상해정도!="기타불명")
```

### 변수들을 factor로 바꿔주기

+	결과변수와 설명변수들을 모두 as.factor()를 통해 변수타입을 factor로 바꾸기.

```c
data.use$요일 <- data.use$요일 %>% as.factor()
data.use$가해자법규위반 <- data.use$가해자법규위반 %>% as.factor()
data.use$노면상태 <- data.use$노면상태 %>% as.factor()
data.use$기상상태 <- data.use$기상상태 %>% as.factor()
data.use$가해당사자종별 <- data.use$가해당사자종별 %>% as.factor()
data.use$가해자신체상해정도 <- data.use$가해자신체상해정도 %>% as.factor()
data.use$가해자보호장구 <- data.use$가해자보호장구 %>% as.factor()
data.use$피해당사자종별 <- data.use$피해당사자종별 %>% as.factor()
data.use$피해자신체상해정도 <- data.use$피해자신체상해정도 %>% as.factor()
data.use$피해자보호장구 <- data.use$피해자보호장구 %>% as.factor()
```

-----------------------------------------------
---------------------------------------------
---------------------------------------------

######## 가해자 데이터 전처리 -시작-########
### 가해자당사자종별이 "이륜차"인 데이터 뽑기
	filter함수를 통해 가해당사자종별이 이륜차인 데이터를 분리했습니다.

### 사용 할 변수만 뽑기("가해당사자종별"을 제거 => 이미 가해자가 이륜차인 데이터만 뽑음)
	

### oversample ("부상"카테고리의 수만큼 oversample) 및 일정한 표본을 뽑기위해 set.seed로 설정(822)
	코드를 재실행시 결과들이 동일하게 나올수 있도록 set.seed를 사용하여 일정한 값을 주고, 
	범주들 중 가장 많은 갯수가 속해있는 "부상"카테고리 수인 45066개로 dplyr패키지의 sample_n 함수를 통해 oversampling하였습니다. 
	replace를 TRUE로 바꾼이유는, 사망과 상해없음에 속해있는 데이터셋의 수가 45066개 보다 적기 때문에 복원추출을 하는 옵션을 넣었습니다.

### oversampling한 데이터 병합시키기
	위에 코드에서 oversampling한 데이터들을 rbind 함수를 통해 병합시켜줍니다.


											# randomforest분석을 할 때마다 임의로 train/ test셋이 분리되기 때문에 별도의 train / test셋은 필요하지 않습니다.
######## 가해자 데이터 전처리 -끝-########
