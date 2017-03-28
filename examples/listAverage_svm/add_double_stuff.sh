cp /home/vagrant/legup-4.0/ip/libs/altera/altfp_adder64_14.v ./
cp /home/vagrant/legup-4.0/ip/libs/altera/altfp_fptosi64_6.v ./
cp /home/vagrant/legup-4.0/ip/libs/altera/altfp_divider64_61.v ./
cp /home/vagrant/legup-4.0/ip/libs/altera/altfp_sitofp64_6.v ./
cat altfp_adder64_14.v >> output/legup_system/synthesis/submodules/listAverage.v
cat altfp_fptosi64_6.v >> output/legup_system/synthesis/submodules/listAverage.v
cat altfp_divider64_61.v >> output/legup_system/synthesis/submodules/listAverage.v
cat altfp_sitofp64_6.v >> output/legup_system/synthesis/submodules/listAverage.v
