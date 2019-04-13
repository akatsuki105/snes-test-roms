#include "libbase.h"

int main() {
FILE *fp = fopen("test.ram", "rb");
FILE *wr = fopen("log.txt", "wb");
  fseek(fp, 512, SEEK_SET);

  for(uint hclock = 0; hclock < 1364; hclock += 2) {
    if(hclock == 530) {
      hclock += 40;
      fprintf(wr, "[DRAM refresh]\r\n\r\n");
    }

    fprintf(wr, "[HC=%4d]\r\n", hclock);

    while(!feof(fp)) {
    uint w, b;
      w  = fgetc(fp);
      w |= fgetc(fp) << 8;
      if(w == 0xffff)break;
      b  = fgetc(fp);
      fprintf(wr, "%0.4x=%0.2x\r\n", w, b);
    }

    fprintf(wr, "\r\n");
  }

uint w;
  w  = fgetc(fp);
  w |= fgetc(fp) << 8;
  fprintf(wr, "HCOUNTER0=%3d\r\n", w);
  w  = fgetc(fp);
  w |= fgetc(fp) << 8;
  fprintf(wr, "VCOUNTER0=%3d\r\n", w);

  w  = fgetc(fp);
  w |= fgetc(fp) << 8;
  fprintf(wr, "HCOUNTER1=%3d\r\n", w);
  w  = fgetc(fp);
  w |= fgetc(fp) << 8;
  fprintf(wr, "VCOUNTER1=%3d\r\n", w);

  fclose(fp);
  fclose(wr);

  return 0;
}
