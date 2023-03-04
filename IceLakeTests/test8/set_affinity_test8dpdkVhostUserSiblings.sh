#!/bin/bash
#/usr/bin/ovs-vsctl set Open_vSwitch . other_config:pmd-cpu-mask=140000000000000014

                                                                
function get_cpumask() {
        local cpu_list=$1
        local pmd_cpu_mask=0
        local bc_math=""
        for cpu in `echo $cpu_list | sed -e 's/,/ /'g`; do
                bc_math="$bc_math + 2^$cpu"
        done
        bc_math=`echo $bc_math | sed -e 's/\+//'`
        pmd_cpu_mask=`echo "obase=16; $bc_math" | bc`
        echo "$pmd_cpu_mask"
}

pmd_cpus="2,4,6,8,66,68,70,72,11,75,13,77"

pmd_cpu_mask=`get_cpumask $pmd_cpus`

echo "pmd-cpu_mask = $pmd_cpu_mask"
/usr/bin/ovs-vsctl set Open_vSwitch . other_config:pmd-cpu-mask=$pmd_cpu_mask
ovs-appctl dpif-netdev/pmd-rxq-show
ovs-vsctl set Interface dpdk-0 options:"n_rxq=2" other_config:pmd-rxq-affinity="0:2,1:4"
ovs-vsctl set Interface dpdk-1 options:"n_rxq=2" other_config:pmd-rxq-affinity="0:6,1:8"

ovs-vsctl set Interface vhost-user-0-n0 options:"n_rxq=2" other_config:pmd-rxq-affinity="0:66,1:68"
ovs-vsctl set Interface vhost-user-1-n0 options:"n_rxq=2" other_config:pmd-rxq-affinity="0:70,1:72"

echo ""
echo "New PMD thread affinities"
ovs-appctl dpif-netdev/pmd-rxq-show



