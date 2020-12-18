/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <string.h>
#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xparameters.h"

char str[] = "Dzordz RR Martin Svet Leda i Vatre";
int i = 0;
int reset;


int main()
{
	init_platform();
	int txt_length;
	int txt_length_res;
	if(strlen(str) % 2 == 1){
		txt_length = (strlen(str) / 2)+1;
		txt_length_res = 2*txt_length-1;
	}
	else
	{
		txt_length = strlen(str) / 2;
		txt_length_res = 2*txt_length;
	}

	u32 txt [2*txt_length];
	u32 mem_txt [txt_length];
	u32 mem_enc[txt_length];
	u16 mem_result[2*txt_length];
	int e_key = 5;
	int private_key = 77;
	int public_key = 221;
	char str_result[txt_length_res];

	printf("Message to encrypt: %s\n",str);
	for (i = 0; i < (2*txt_length) ; i++) {
		txt[i] = str[i];
		printf("txt[%d]: %d, ",i, txt[i]);

	}

	//-----------------Encryption test------------------
	printf("\nEncryption test !!!\n");

	for(i = 0; i < txt_length; i++)
	{
		mem_txt [i] = (txt[2*i] << 16) | txt[2*i+1];
		printf("%d: %d,  ", i, mem_txt[i]);
	}

	//setting reset to 1
	Xil_Out32(0x43C00000 + 28, 1);
	reset = Xil_In32(0x43C00000 + 28);
	printf("\nreset is %d\n", reset);

    //setting reset to 0
	Xil_Out32(0x43C00000 + 28, 0);
	reset = Xil_In32(0x43C00000 + 28);
	printf("reset is %d\n", reset);

	//System is ready
	printf("ready is: %d\n\r",Xil_In32(0x43C00000 + 32));


	//Writing txt in memory BRAM_A
	for (i = 0; i < txt_length; i++)
	{
		Xil_Out32(0x40000000 + i*4,mem_txt[i]);
		printf("mem_txt [%d\]: %d \n", i,Xil_In32(0x40000000 + i*4));
	}

	//Sending keys and length to RSA module
	Xil_Out32(0x43C00000 , e_key);
	printf("\re_key is: %d \n",Xil_In32(0x43C00000));

	Xil_Out32(0x43C00000 + 4, private_key);
	printf("private_key is: %d\n",Xil_In32(0x43C00000 + 4));

	Xil_Out32(0x43C00000 + 8, public_key);
	printf("public_key is: %d\n",Xil_In32(0x43C00000 + 8));

	Xil_Out32(0x43C00000 + 12, 4*txt_length);
	printf("txt_length is: %d\n",Xil_In32(0x43C00000 + 12));


	//If ready is 1 we set start bit to 1 so system can start encryption
	if (Xil_In32(0x43C00000 + 32) == 1){

		//Setting bit for encryption
		Xil_Out32(0x43C00000 + 16, 1);
		printf("start_enc is: %d \n",Xil_In32(0x43C00000 + 16));

		Xil_Out32(0x43C00000 + 20, 0);
		printf("start_dec is: %d \n",Xil_In32(0x43C00000 + 20));

		Xil_Out32(0x43C00000 + 24, 1);
		printf("start is: %d \n",Xil_In32(0x43C00000 + 24));

	}

	//Clearing start bit
	Xil_Out32(0x43C00000 + 24, 0);
	printf("start is: %d \n",Xil_In32(0x43C00000 + 24));

	Xil_Out32(0x43C00000 + 16, 0);
	printf("start_enc is: %d \n",Xil_In32(0x43C00000 + 16));

	Xil_Out32(0x43C00000 + 20, 0);
	printf("start_dec is: %d \n",Xil_In32(0x43C00000 + 20));

	//Waiting for encryption to finish
	while(!(Xil_In32(0x43C00000 + 32)));
	printf("\rEncyption is finished !!! \n");
	printf("ready is: %d\n\r",Xil_In32(0x43C00000 + 32));

	//Writing results of encryption into SDK terminal
	printf("Encryption results: \n");
	for (i = 0; i < (txt_length_res) ;i++)
	{
		mem_result[i]= Xil_In32(0x42000000 + i*4);
		printf("%d: %d,  ", i, mem_result[i]);
	}

	printf("\nready is: %d\n",Xil_In32(0x43C00000 + 32));

	//-----------------Decryption test------------------
	printf("\nDecryption test !!!\n");
	for(i = 0; i < txt_length; i++)
	{
		mem_enc[i] = (mem_result[2*i] << 16) | mem_result[2*i+1];
		printf("%d: %d,  ", i, mem_enc[i]);
	}


	//setting reset to 1
	Xil_Out32(0x43C00000 + 28, 1);
	reset = Xil_In32(0x43C00000 + 28);
	printf("\nreset is %d\n", reset);

    //setting reset to 0
	Xil_Out32(0x43C00000 + 28, 0);
	reset = Xil_In32(0x43C00000 + 28);
	printf("reset is %d\n", reset);

	//System is ready
	printf("ready is: %d\n\r",Xil_In32(0x43C00000 + 32));

	//Writing txt in memory BRAM_A
	for (i = 0; i < txt_length; i++)
	{
		Xil_Out32(0x40000000 + i*4,mem_enc[i]);
		printf("mem_enc [%d\]: %d \n", i,Xil_In32(0x40000000 + i*4));
	}

	//If ready is 1 we set start bit to 1 so system can start encryption
	if (Xil_In32(0x43C00000 + 32) == 1){

		//Setting bit for decryption
		Xil_Out32(0x43C00000 + 16, 0);
		printf("\rstart_enc is: %d \n",Xil_In32(0x43C00000 + 16));

		Xil_Out32(0x43C00000 + 20, 1);
		printf("start_dec is: %d \n",Xil_In32(0x43C00000 + 20));

		Xil_Out32(0x43C00000 + 24, 1);
		printf("start is: %d \n",Xil_In32(0x43C00000 + 24));

	}

	//Clearing start bit
	Xil_Out32(0x43C00000 + 24, 0);
	printf("start is: %d \n",Xil_In32(0x43C00000 + 24));

	Xil_Out32(0x43C00000 + 16, 0);
	printf("start_enc is: %d \n",Xil_In32(0x43C00000 + 16));

	Xil_Out32(0x43C00000 + 20, 0);
	printf("start_dec is: %d \n",Xil_In32(0x43C00000 + 20));

	//Waiting for decryption to finish
	while(!(Xil_In32(0x43C00000 + 32)));
	printf("\rDecyption is finished !!! \n");
	printf("ready is: %d\n\r",Xil_In32(0x43C00000 + 32));

	//Writing results of decryption into SDK terminal
	printf("Decryption results: \n");
	for (i = 0; i < (txt_length_res) ;i++)
	{
		mem_result[i]= Xil_In32(0x42000000 + i*4);
		printf("%d: %d,  ", i, mem_result[i]);
	}
	printf("\nDecrypted message: \n");
	for (i = 0; i < (txt_length_res) ;i++)
	{
		str_result[i]= (char)mem_result[i];
		printf("%c", str_result[i]);
	}
	cleanup_platform();
	return 0;
}
