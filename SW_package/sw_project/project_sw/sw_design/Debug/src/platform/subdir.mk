################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/platform/interface.c \
../src/platform/platform.c 

OBJS += \
./src/platform/interface.o \
./src/platform/platform.o 

C_DEPS += \
./src/platform/interface.d \
./src/platform/platform.d 


# Each subdirectory must supply rules for building sources it contributes
src/platform/%.o: ../src/platform/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I/users/students/r0792566/Documents/DDP/SW_package/sw_project/project_sw/rsa_project_wrapper/export/rsa_project_wrapper/sw/rsa_project_wrapper/standalone_domain/bspinclude/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


