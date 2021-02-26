#!/bin/bash
set -e

if [[ "$1" = "emul" ]]; then

  echo -e "\e[31m-= Анализ предыдущих компиляций =-\e[0m"

  # проверка на предыдущую компиляцию
  if [[ -e "${RES}/kver" ]]; then
    # существуют результаты предыдущей компиляции
    echo -e "\e[33m...обнаружен результат предудущих компиляций\e[0m"

    if [[ "$(cat ${RES}/kver)" == "$(uname -r)" ]]; then
      # текущая версия ядра совпадает с результатами предыдущей компиляции
      echo -e "\e[33m...текущая версия ядра совпадает с результатами предыдущей компиляции\e[0m"
    else
      # текущая версия ядра не совпадает с результатами предыдущей компиляции
      echo -e "\e[33m...текущая версия ядра не совпадает с результатами предыдущей компиляции\e[0m"

      # удалим все существующие файлы
      echo -e "\e[33m...очистка каталога результатов\e[0m"
      rm -rf ${RES}/*.*
    fi
  else
    # первая компиляция
    echo -e "\e[33m...первая компиляция\e[0m"
    # удалим все существующие файлы
    echo -e "\e[33m...очистка каталога результатов\e[0m"
    rm -rf ${RES}/*.*
  fi

  #########################################
  # драйвер usb-vhci
  #########################################

  echo -e "\e[31m-= Компиляция драйвера usb-vhci =-\e[0m"

  if [[ -e "${RES}/usb-vhci-hcd.ko" ]] && [[ -e "${RES}/usb-vhci-iocifc.ko" ]]; then
    # драйвер уже скомпилирован
    echo -e "\e[33m...драйвер usb-vhci уже скомпилирован\e[0m"
  else
    # драйвер не скомпилирован или скомпилирован не полностью
    echo -e "\e[33m...драйвер usb-vhci еще не скомпилирован\e[0m"

    # на всякий случай удалим целевые файлы (например, если есть только один из них)
    if [ -e "${RES}/usb-vhci-hcd.ko" ]; then
      echo -e "\e[33m...удаляем файл usb-vhci-hcd.ko\e[0m"
      rm -f "${RES}/usb-vhci-hcd.ko"
      echo -e "\e[33m...файл usb-vhci-hcd.ko удален\e[0m"
    fi

    if [ -e "${RES}/usb-vhci-hcd.ko" ]; then
      echo -e "\e[33m...удаляем файл usb-vhci-iocifc.ko\e[0m"
      rm -f "${RES}/usb-vhci-iocifc.ko"
      echo -e "\e[33m...файл usb-vhci-iocifc.ko удален\e[0m"
    fi

    # собираем драйвер виртуального USB
    echo -e "\e[33m...компилируем драйвер usb-vhci\e[0m"
    cd "${SRC}/${V_USB_DRIVER_VER}"
    make KVERSION="${KERNEL_VER}" KSRC="${SRC}/kernels/${KERNEL_VER}"

    # переносим скомпилированные файлы в каталог результата
    cp -f -p ${SRC}/${V_USB_DRIVER_VER}/usb-vhci-hcd.ko ${RES}/
    cp -f -p ${SRC}/${V_USB_DRIVER_VER}/usb-vhci-iocifc.ko ${RES}/

    # переносим заголовочный файл в общий каталог (понадобтся для компиляции libusb_vhci)
    cp -f -p ${SRC}/${V_USB_DRIVER_VER}/usb-vhci.h /usr/include/linux/

    echo -e "\e[33m...драйвер usb-vhci скомпилирован\e[0m"
  fi

  #########################################
  # библиотека libusb_vhci (нужна для usbhasp)
  #########################################

  echo -e "\e[31m-= Компиляция библиотеки libusb_vhci =-\e[0m"

  cd "${SRC}/${V_USB_LIB_VER}"

  if [[ -e "${RES}/libusb_vhci.so" ]] && [[ -e "${RES}/libusb_vhci.so.0" ]] && [[ -e "${RES}/libusb_vhci.so.0.0.0" ]] && [[ -e "${RES}/libusb_vhci.a" ]] && [[ -e "${RES}/libusb_vhci.la" ]]; then
    # библиотека уже скомпилирована

    echo -e "\e[33m...библиотека libusb_vhci уже скомпилирована\e[0m"
  else
    # библиотека не скомпилирована
    echo -e "\e[33m...библиотека libusb_vhci еще не скомпилирована\e[0m"

    # на всякий случай удалим целевые файлы (например, если есть только один из них)
    rm -f "${RES}/libusb_vhci.*"
    echo -e "\e[33m...файлы библиотеки libusb_vhci удалены\e[0m"

    # компилируем библиотеку
    echo -e "\e[33m...компилируем библиотеку libusb_vhci\e[0m"
    ./configure
    make

    # переносим скомпилированные файлы в каталог результата
    cp -f -p -P ${SRC}/${V_USB_LIB_VER}/src/.libs/*.so* ${RES}/
    cp -f -p ${SRC}/${V_USB_LIB_VER}/src/.libs/*.a ${RES}/
    cp -f -p ${SRC}/${V_USB_LIB_VER}/src/.libs/*.la ${RES}/

    # переносим заголовочный файл в общий каталог (понадобтся для компиляции usbhasp)
    cp -f -p ${SRC}/${V_USB_LIB_VER}/src/libusb_vhci.h /usr/local/include/
    # переносим файлы библиотеки в общий каталог (понадобтся для компиляции usbhasp)
    cp -f -p -P ${SRC}/${V_USB_LIB_VER}/src/.libs/*.so* /usr/lib64/

    echo -e "\e[33m...библиотека libusb_vhci скомпилирована\e[0m"
  fi

  #########################################
  # эмулятор usbhasp
  #########################################

  echo -e "\e[31m-= Компиляция эмулятора usbhasp =-\e[0m"

  if [[ -e "${RES}/usbhasp" ]]; then
    # эмулятор уже скомпилирован
    echo -e "\e[33m...эмулятор usbhasp уже скомпилирован\e[0m"
  else
    # эмулятор еще не скомпилирован
    echo -e "\e[33m...эмулятор usbhasp еще не скомпилирован\e[0m"
    cd "${SRC}/UsbHasp"
    make

    # переносим скомпилированные файлы в каталог результата
    cp -f ${SRC}/UsbHasp/dist/Release/GNU-Linux/usbhasp ${RES}/
    chmod 555 ${RES}/usbhasp            # владелец: чтение и выполнение; группа: чтение и выполнение; остальные: чтение и выполнение
    echo -e "\e[33m...эмулятор usbhasp скомпилирован\e[0m"
  fi

  #########################################
  # драйвер HASP, дампы ключей защиты
  #########################################
  echo -e "\e[31m-= Вспомогательные файлы =-\e[0m"

  # дистрибутив драйвера HASP защиты переместим в каталог результата
  cp  -f -p ${TMP}/hasp/*.rpm ${RES}/
  chmod 644 ${RES}/*.rpm                # владелец: чтение, запись; группа: чтение; остальные: чтение
  # дампы ключей защиты переместим в каталог результата
  cp  -f -p ${TMP}/keys/*.json ${RES}/
  chmod 644 ${RES}/*.json               # владелец: чтение, запись; группа: чтение; остальные: чтение
  # unit-файл сервиса usbhasp переместим в каталог результата
  cp  -f -p ${TMP}/usbhaspd.service ${RES}/
  chmod 644 ${RES}/usbhaspd.service     # владелец: чтение, запись; группа: чтение; остальные: чтение
  #########################################
  # сохраним версию ядра, под которым компилировали
  #########################################

  # версию ядра, под которым компилировался драйвер, сохраним в файл
  echo $(uname -r) > ${RES}/kver
  chmod 644 ${RES}/kver                 # чтение всем, кроме владельца

  echo -e "\e[33m...вспомогательные файлы перенесены\e[0m"

  # успешное завершение
  exit 0
fi

exec "$@"