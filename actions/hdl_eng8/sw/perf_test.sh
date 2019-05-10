#!/bin/bash
HEADER="2KiB,4KiB,8KiB,16KiB,32KiB,64KiB,128KiB,256KiB,512KiB,1MiB,2MiB,4MiB,8MiB,16MiB"
MMIO_INT=""
JM_POLL=""
for s in 2KiB 4KiB 8KiB 16KiB 32KiB 64KiB 128KiB 256KiB 512KiB 1MiB 2MiB 4MiB 8MiB 16MiB
do
    echo "MMIO mode running -> ${s}"
    mmio_result=`./hdl_eng8 -j 64 -s ${s} | grep -i 'sustained bandwidth' | cut -d' ' -f 3`
    echo "${mmio_result}"
    MMIO_INT+="${mmio_result},"
done

for s in 2KiB 4KiB 8KiB 16KiB 32KiB 64KiB 128KiB 256KiB 512KiB 1MiB 2MiB 4MiB 8MiB 16MiB
do
    echo "JM mode running -> ${s}"
    jm_result=`./hdl_eng8 -m -p -j 64 -s ${s} | grep -i 'sustained bandwidth' | cut -d' ' -f 3`
    echo "${jm_result}"
    JM_POLL+="${jm_result},"
done


echo $HEADER
echo $MMIO_INT
echo $JM_POLL
