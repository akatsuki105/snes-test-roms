#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>

typedef unsigned char  uint8;
typedef unsigned short uint16;
typedef unsigned long  uint32;

FILE *fp;

struct _op {
  uint8 code_length;
  uint8 cycles;
  uint8 code[8];
} op[64] = {
  { 1, 14, { 0xea                   } }, //0
  { 2, 16, { 0x89, 0x00             } }, //1
  { 1, 20, { 0xeb                   } }, //2
  { 2, 24, { 0xa5, 0x00             } }, //3
  { 3, 30, { 0xad, 0x00, 0x21       } }, //4
  { 3, 32, { 0xad, 0x00, 0x00       } }, //5
  { 2, 34, { 0xeb, 0xea             } }, //6 -- 2+0
  { 3, 36, { 0xeb, 0x89, 0x00       } }, //7 -- 2+1
  { 3, 38, { 0xa5, 0x00, 0xea       } }, //8 -- 3+0
  { 4, 40, { 0xa5, 0x00, 0x89, 0x00 } }, //9 -- 3+1
};

void write_op(int opnum) {
  fprintf(fp, "  db ");
  for(int i=0;i<op[opnum].code_length;i++) {
    fprintf(fp, "$%0.2x", op[opnum].code[i]);
    if(i != (op[opnum].code_length - 1))fprintf(fp, ",");
  }
  fprintf(fp, "\r\n");
}

void generate(int n, int cycles) {
char p[64];
int pos = 0;
  fprintf(fp, "__cycle_skip_%d:\r\n", n);

  *p = 0;
//i'm sure this could be done using some sort of algorithm,
//but like hell if I feel like creating one... easier to just
//create a table of all possible cycle combinations instead.
  switch(cycles) {
  case 156:strcpy(p, "55544");  break;
  case 158:strcpy(p, "55554");  break;
  case 160:strcpy(p, "9999");   break;
  case 162:strcpy(p, "88833");  break;
  case 164:strcpy(p, "98833");  break;
  case 166:strcpy(p, "99833");  break;
  case 168:strcpy(p, "99933");  break;
  case 170:strcpy(p, "444442"); break;
  case 172:strcpy(p, "444452"); break;
  case 174:strcpy(p, "444552"); break;
  case 176:strcpy(p, "445552"); break;
  case 178:strcpy(p, "455552"); break;
  case 180:strcpy(p, "555552"); break;
  case 182:strcpy(p, "555562"); break;
  case 184:strcpy(p, "555662"); break;
  case 186:strcpy(p, "556662"); break;
  case 188:strcpy(p, "566662"); break;
  case 190:strcpy(p, "666662"); break;
  case 192:strcpy(p, "666672"); break;
  case 194:strcpy(p, "666772"); break;
  case 196:strcpy(p, "667772"); break;
  case 198:strcpy(p, "677772"); break;
  case 200:strcpy(p, "777772"); break;
  case 202:strcpy(p, "777782"); break;
  case 204:strcpy(p, "777882"); break;
  case 206:strcpy(p, "778882"); break;
  case 208:strcpy(p, "788882"); break;
  case 210:strcpy(p, "888882"); break;
  case 212:strcpy(p, "888892"); break;
  case 214:strcpy(p, "888992"); break;
  case 216:strcpy(p, "889992"); break;
  case 218:strcpy(p, "899992"); break;
  case 220:strcpy(p, "999992"); break;
  case 222:strcpy(p, "6666652");break;
  case 224:strcpy(p, "6666662");break;
  case 226:strcpy(p, "6666672");break;
  case 228:strcpy(p, "6666772");break;
  case 230:strcpy(p, "6667772");break;
  case 232:strcpy(p, "6677772");break;
  case 234:strcpy(p, "6777772");break;
  case 236:strcpy(p, "7777772");break;
  case 238:strcpy(p, "7777782");break;
  case 240:strcpy(p, "7777882");break;
  case 242:strcpy(p, "7778882");break;
  case 244:strcpy(p, "7788882");break;
  case 246:strcpy(p, "7888882");break;
  case 248:strcpy(p, "8888882");break;
  case 250:strcpy(p, "8888892");break;
  case 252:strcpy(p, "8888992");break;
  case 254:strcpy(p, "8889992");break;
  }

  if(!*p) { printf("error: missing %d\n", cycles); return; }

//verify that the above cycle calculations are correct...
int c = 0;
  for(int i=0;i<strlen(p);i++) {
  int o = p[i] - '0';
    write_op(o);
    c += op[o].cycles;
  }

  if(c != cycles) {
    printf("error: %d != %d [%s]\n", c, cycles, p);
  }

  fprintf(fp, "  plp : rtl\r\n");
}

int main() {
int i, z;
  fp = fopen("cyclegen.asm", "wb");
  for(i=156,z=0;i<=254;i+=2,z++) {
    generate(z, i);
  }
  fprintf(fp, "cycle_skip_table:\r\n");
  for(i=0;i<50;i++) {
    fprintf(fp, "  dw __cycle_skip_%d\r\n", i);
  }
  fclose(fp);
  printf("done\n");
  getch();
  return 0;
}
