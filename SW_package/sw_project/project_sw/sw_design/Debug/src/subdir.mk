################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/main.c \
../src/montgomery.c \
../src/mp_arith.c \
../src/test.c \
../src/testvector.c \
../src/warmup.c 

S_UPPER_SRCS += \
../src/asm_func.S 

OBJS += \
./src/asm_func.o \
./src/main.o \
./src/montgomery.o \
./src/mp_arith.o \
./src/test.o \
./src/testvector.o \
./src/warmup.o 

S_UPPER_DEPS += \
./src/asm_func.d 

C_DEPS += \
./src/main.d \
./src/montgomery.d \
./src/mp_arith.d \
./src/test.d \
./src/testvector.d \
./src/warmup.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I/users/students/r0792566/Documents/DDP/SW_package/sw_project/project_sw/rsa_project_wrapper/export/rsa_project_wrapper/sw/rsa_project_wrapper/standalone_domain/bspinclude/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I/users/students/r0792566/Documents/DDP/SW_package/sw_project/project_sw/rsa_project_wrapper/export/rsa_project_wrapper/sw/rsa_project_wrapper/standalone_domain/bspinclude/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


