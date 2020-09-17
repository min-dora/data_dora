# randomforest_README


### package설치 (caret, dplyr, randomForest, ggplot2)

```c 

install.packages("caret")
    
install.packages("dplyr")
    
install.packages("randomForest")
    
install.packages("ggplot2")
```

### library 불러오기

```c
library(caret)
library(dplyr)
library(randomForest)
library(ggplot2)
```


### 원본데이터 불러오기
+ 코드를 실행하여 첨부한 원본데이터 (가해자차종 또는 피해자차종이 이륜차인 교통사고 정보(2015~2019년).csv)를 불러옵니다.
```c
data <- read.csv(file.choose())
```


### 필요한 변수 선택
+ select함수를 통해 원본데이터에서 사용할 변수들만 뽑아옵니다.
```c
data.use <- select(data, 요일, 가해자법규위반, 노면상태, 기상상태, 가해당사자종별, 가해자신체상해정도, 가해자보호장구, 피해당사자종별, 피해자신체상해정도, 피해자보호장구)
```

### 신체상해정도(중상, 경상, 부상신고)를 부상으로 바꿔주기 => (사망, 부상, 상해없음)
+ ifelse함수를 통해 신체상해정도가 "중상, 경상, 부상신고"인 것들을 부상으로 바꿔주고 사망과 상해없음은 그대로 불러옵니다.
```c
data.use$가해자신체상해정도 <- ifelse(data.use$가해자신체상해정도=="중상"|data.use$가해자신체상해정도=="경상"|data.use$가해자신체상해정도=="부상신고", "부상", data.use$가해자신체상해정도)
data.use$가해자신체상해정도 %>% table()

data.use$피해자신체상해정도 <- ifelse(data.use$피해자신체상해정도=="중상"|data.use$피해자신체상해정도=="경상"|data.use$피해자신체상해정도=="부상신고", "부상", data.use$피해자신체상해정도)
data.use$피해자신체상해정도 %>% table()
```














