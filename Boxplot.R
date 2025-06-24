# Установка пакетов (если нужно)
if (!require("quantmod")) install.packages("quantmod")
if (!require("lubridate")) install.packages("lubridate")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")
if (!require("zoo")) install.packages("zoo")
if (!require("plotly")) install.packages("plotly") # Для интерактивных графиков

# Загрузка библиотек
library(quantmod)
library(lubridate)
library(ggplot2)
library(dplyr)
library(zoo)
library(plotly)

# Загрузка данных AAPL (например, за последние 6 месяцев)
getSymbols("AAPL", src = "yahoo", from = Sys.Date() - 180, to = Sys.Date())

# Создаем data.frame с недельными группами
aapl_data <- data.frame(
  Date = index(AAPL),
  Price = AAPL$AAPL.Close,
  Week = floor_date(index(AAPL), "week")
)

# Рассчитываем медиану для каждой недели
weekly_medians <- aapl_data %>%
  group_by(Week) %>%
  summarise(Median_Price = median(AAPL.Close))

# Добавляем скользящую среднюю (например, за 2 недели)
weekly_medians <- weekly_medians %>%
  mutate(
    Rolling_Median = zoo::rollmean(Median_Price, k = 2, fill = NA, align = "right")
  ) %>%
  # Заменяем NA на последнее известное значение (чтобы линия не прерывалась)
  tidyr::fill(Rolling_Median, .direction = "down")

# Объединяем с исходными данными
aapl_data <- left_join(aapl_data, weekly_medians, by = "Week")

### Строим ggplot объект
p <- ggplot(aapl_data, aes(x = Week)) +
  geom_boxplot(aes(y = AAPL.Close, group = Week), fill = "lightblue", alpha = 0.7) +
  geom_line(aes(y = Rolling_Median), color = "red", linewidth = 1.2, na.rm = FALSE) +
  labs(
    title = "Недельные цены AAPL со скользящей медианой (2 недели)",
    x = "Неделя",
    y = "Цена ($)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Преобразуем в интерактивный график
ggplotly(p, tooltip = c("y", "x", "group")) %>%
  layout(
    hovermode = "x unified",
    xaxis = list(
      title = "Неделя",
      tickangle = -45
    ),
    yaxis = list(
      title = "Цена ($)"
    )
  )
