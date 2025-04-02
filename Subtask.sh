#!/bin/bash

# 1) awk '/Всяк[а-яА-Я]*/ {print $0}' file.txt
# 2) awk '/Мирослав[а-яА-Я]*|Миро[а-яА-Я]*|Слав[а-яА-Я]*/ {print $0}' file.txt
# 3) awk '/(03[1-8]\d|032|034|035|036|037|038)/ {print $0}' file.txt

# 4) Виводить імена користувачів з оболонкою /bin/bash
echo "Користувачі з оболонкою /bin/bash:"
grep "/bin/bash$" /etc/passwd | awk -F: '{print $1}'

# 5) Виводить рядок, що починається з "daemon" з файлу /etc/group
echo "Рядок з 'daemon' з /etc/group:"
awk '/^daemon/' /etc/group

# 6) Виводить рядки, що не містять "daemon" з файлу /etc/group
echo "Рядки без 'daemon' з /etc/group:"
awk '!/daemon/' /etc/group

# 7) Підраховує кількість файлів README у поточному каталозі та його підкаталогах
echo "Кількість файлів README:"
find . -type f -name "README" | wc -l

# 8) Виводить файли з домашнього каталогу, змінені протягом останніх 600 хвилин
echo "Файли, змінені за останні 600 хвилин:"
find ~ -type f -mmin -600
