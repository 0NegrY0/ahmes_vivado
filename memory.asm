#codigo assembly de multiplicacao de 2 numeros inteiros positivos no ahmes
#carlos negri - 00333174

  0   32 136   LDA 136       	#carrega o natural 8
  2   16 132   STA 132		#salva no contadorInterno
  4   32 134   LDA 134		#carrega o natural 0
  6   16 130   STA 130		#salva na metade A do produto
  8   32 129   LDA 129		#carrega o multiplicador
 10   16 133   STA 133		#salva na memoria auxiliar
 12   32 133   LDA 133		#carrega a memoria auxiliar
 14  224       SHR		#shift right
 15   16 133   STA 133		#salva o resultado do shift na memoria auxiliar
 17  180  25   JNC 25		#jump condicional
 19   32 128   LDA 130		#carrega a parte A do produto
 21   48 130   ADD 128		#soma com o multiplicando
 23   16 130   STA 130		#salva na parte A do produto
 25   32 130   LDA 130		#carrega a parte A do produto
 27  226       ROR		#rotate right
 28   16 130   STA 130		#salva na metade A do produto
 30   32 131   LDA 131		#carrega a parte B do produto
 32  226       ROR		#rotate right
 33   16 131   STA 131		#slava na parte B do produto
 35   32 132   LDA 132		#carrega ao contador interno
 37  112 135   SUB 135		#-1
 39   16 132   STA 132		#salva no contador interno
 41  164  12   JNZ 12		#jump condicional
 43  240       HLT		#fim do programa

128    0       Multiplicando     
129    0       Multiplicador
130    0       MetadeAdoProduto
131    0       MetadeBdoProduto
132    0       contadorInterno
133    0       memoriaAuxiliar
134    0       natural_0
135    1       natural_1
136    8       natural_8
