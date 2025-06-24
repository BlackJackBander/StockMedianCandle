# Загрузка библиотек
library(quantmod)
library(lubridate)
library(ggplot2)

# Загрузка данных AAPL (например, за последние 3 месяца)
getSymbols("AAPL", src = "yahoo", from = Sys.Date() - 365, to = Sys.Date())

# Преобразуем в data.frame и добавляем неделю
aapl_data <- data.frame(
  Date = index(AAPL),
  Price = AAPL$AAPL.Close,  # Используем правильное название столбца
  Week = floor_date(index(AAPL), "month") # Группируем по неделям
)

### Вариант 2: Boxplot в ggplot2 (исправленный)
ggplot(aapl_data, aes(x = Week, y = AAPL.Close, group = Week)) +
  geom_boxplot(fill = "lightblue", alpha = 0.7) +
  labs(title = "Недельные цены закрытия AAPL",
       x = "Неделя",
       y = "Цена ($)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
