----------------------------------------------------------------------------------
-- Company: UFRGS
-- Engineer: Carlos Negri - 00333174
-- 
-- Create Date: 26.01.2023 19:01:21
-- Design Name: 
-- Module Name: datapath_ahmes - Behavioral
-- Project Name: Trabalho SD Ahmes
-- Target Devices: 
-- Tool Versions: 
-- Description: Trabalho da disciplina de Sistemas Digitais (2022/2)
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 1.01 - Teoricamente funcionando
-- Additional Comments: 
--
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity datapath is
Port ( clk : in  STD_LOGIC;
       rst : in  STD_LOGIC;
       err : out STD_LOGIC_VECTOR(0 downto 0)        
     );
end datapath;

architecture Behavioral of datapath is

--COMPONENT mem
COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    --ena : IN STD_LOGIC
  );
END COMPONENT;

--variaveis utilizadas                          codigos para as funcoes da ula podem ser modificados na versao final

    --LINK
         signal incPC : STD_LOGIC;
         signal cargaPC : STD_LOGIC;
         signal cargaACC : STD_LOGIC;
         signal selULA : STD_LOGIC_VECTOR (3 downto 0);
         signal cargaREM : STD_LOGIC;
         signal cargaRI : STD_LOGIC;
          
         signal sel : STD_LOGIC;
         signal mux2 : STD_LOGIC;
         signal cargaRDM : STD_LOGIC;
          
          
         signal setN : STD_LOGIC;
         signal setZ : STD_LOGIC;
         signal setC : STD_LOGIC;
         signal setB : STD_LOGIC;
         signal setV : STD_LOGIC;
          
          
         signal saidaN : STD_LOGIC;
         signal saidaZ : STD_LOGIC;
         signal saidaC : STD_LOGIC;
         signal saidaB : STD_LOGIC;
         signal saidaV : STD_LOGIC;
 
         signal saidaRI :STD_LOGIC_VECTOR (7 downto 0);
       
       
         signal WR : STD_LOGIC_VECTOR(0 downto 0);
         
   --CONTROLE
   type state is (t0, t1, t2, t3, t4, t5, t6, t7, hlt, errorState, w1_1, w1_2, w1_3, w1_4, w2_1, w2_2, w2_3, w2_4, w3_1, w3_2, w3_3, w3_4);

    signal currentState, nextState : state;

    signal nopOP, staOP, ldaOP, addOP, orOP, andOP, notOP, subOP, jmpOP, jnOP, jpOP, jvOP, jnvOP, jzOP, jnzOP, jcOP, jncOP, jbOP, jnbOP, shrOP, shlOP, rorOP, rolOP, hltOP, rotate, operators, jmpT, jmpF : std_logic;


   --ULA
   signal ula_result : std_logic_vector(7 downto 0);
   signal tempA : std_logic_vector(8 downto 0);
   signal tempS : std_logic_vector(8 downto 0);
   signal Cin : std_logic;
   signal N : std_logic;
   signal Z : std_logic;
   signal C : std_logic;
   signal B : std_logic;
   signal V : std_logic;
   
   
   --signal ula_result_cond : std_logic_vector (8 downto 0);
   
   signal intN : std_logic;
   signal intZ : std_logic;
   signal intC : std_logic;
   signal intB : std_logic;
   signal intV : std_logic;

   --MEM
   signal dadoFinal : STD_LOGIC_VECTOR (7 downto 0);                --ENDERECO (END)
   signal dadoEntrada : STD_LOGIC_VECTOR (7 downto 0);                    
   signal dadoSaida : STD_LOGIC_VECTOR (7 downto 0);


   --PC
   signal saidaPC : std_logic_vector(7 downto 0);
   signal regPC : std_logic_vector (7 downto 0) := (others => '0');

    --ACC    
    signal saidaACC : std_logic_vector (7 downto 0);
    signal regACC : std_logic_vector (7 downto 0) := (others => '0');
   
    --REM
    signal entradaREM : std_logic_vector (7 downto 0);
    signal regREM : std_logic_vector (7 downto 0) := (others => '0');

   --RDM
     signal entradaRDM : std_logic_vector (7 downto 0);
     signal regRDM : std_logic_vector (7 downto 0) := (others => '0');
     signal saidaRDM : std_logic_vector (7 downto 0);

    --RI
     --signal saidaRI : std_logic_vector(7 downto 0);
     signal regRI : std_logic_vector (7 downto 0) := (others => '0');
--//////////////////////////////////////////////////////////////////////////////////////
begin

process (clk,rst)
	begin
		if rst = '1' THEN
			currentState <= t0;
		elsif clk'event and clk = '1' then
			currentState <= nextState;
		end if;
    end process;
		
process (currentState, saidaRI, rolOP, rorOP, shlOP, shrOP, ldaOP, addOP, subOP, andOP, orOP, jmpOP, jnOP, saidaN, jpOP, jvOP, saidaV, jnvOP, jcOP, saidaC, jncOP, jzOP, saidaZ, jnzOP, jbOP, saidaB, jnbOP, operators, staOP, jmpT, jmpF, hltOP, notOP, rotate)
    begin
        setB <= '0';
        setZ <= '0';
        setC <= '0';
        setV <= '0';
        setN <= '0';
        incPC <= '0';
        cargaACC <= '0';
        cargaPC <= '0';
        cargaREM <= '0'; 
        sel <= '0';
        mux2 <= '0';
        cargaRDM <= '0'; 
        cargaRI <= '0';
        selULA <= "0000";
        WR <= "0";
        
        --zera decod
                nopOP  <= '0';
                staOP  <= '0';
                ldaOP  <= '0';
                addOP  <= '0';
                orOP   <= '0';
                andOP  <= '0';
                notOP  <= '0';
                subOP  <= '0';
                jmpOP  <= '0';
                jnOP   <= '0';
                jpOP   <= '0';
                jvOP   <= '0';
                jnvOP  <= '0';
                jzOP   <= '0';
                jnzOP  <= '0';
                jcOP   <= '0';
                jncOP  <= '0';
                jbOP   <= '0';
                jnbOP  <= '0';
                shrOP  <= '0';
                shlOP  <= '0';
                rorOP  <= '0';
                rolOP  <= '0';
                hltOP  <= '0';
                rotate <= '0';
                operators <= '0';
                jmpT <= '0';
                jmpF <= '0';
        
        --DECOD
        case saidaRI(7 downto 4) is
            when "0000" =>
                nopOP <= '1';
            when "0001" =>
                staOP <= '1';
            when "0010" =>
                ldaOP <= '1';
            when "0011" =>
                addOP <= '1';
            when "0100" =>
                orOP <= '1';
            when "0101" =>
                andOP <= '1';
            when "0110" =>
                notOP <= '1';
            when "0111" =>
                subOP <= '1';
            when "1000" =>
                jmpOP <= '1';
            when "1001" =>
                case saidaRI(3 downto 2) is
                    when "00" =>
                        jnOP <= '1';
                    when "01" =>
                        jpOP <= '1';
                    when "10" =>
                        jvOP <= '1';
                    when others =>
                        jnvOP <= '1';
                end case;
            when "1010" =>
                if saidaRI(3 downto 2) = "00" then
                    jzOP <= '0';
                elsif saidaRI(3 downto 2) = "01" then
                    jnzOP <= '0';
                end if;
            when "1011" =>
               case saidaRI(3 downto 2) is
                    when "00" =>
                        jcOP <= '1';
                    when "01" =>
                        jncOP <= '1';
                    when "10" =>
                        jbOP <= '1';
                    when others =>
                        jnbOP <= '1';
                end case;
            when "1110" =>
                case saidaRI(1 downto 0) is
                    when "00" =>
                        shrOP <= '1';
                    when "01" =>
                        shlOP <= '1';
                    when "10" =>
                        rorOP <= '1';
                    when others =>
                        rolOP <= '1';
                end case;
            when "1111" =>
                hltOP <= '1';
            when others =>
                nopOP <= '1';
        end case;
        
        rotate <= rolOP or rorOP or shlOP or shrOP;
        operators <= ldaOP or addOP or subOP or andOP or orOP;
        jmpT <= (jmpOP or
            (jnOP and saidaN) or (jpOP and not saidaN) or
            (jvOP and saidaV) or (jnvOP and not saidaV) or
            (jcOP and saidaC) or (jncOP and not saidaC) or
            (jzOP and saidaZ) or (jnzOP and not saidaZ) or
            (jbOP and saidaB) or (jnbOP and not saidaB));
        jmpF <= (
            (jnOP and not saidaN) or (jpOP and saidaN) or
            (jvOP and not saidaN) or (jnvOP and saidaN) or
            (jcOP and not saidaN) or (jncOP and saidaN) or
            (jzOP and not saidaN) or (jnzOP and saidaN) or
            (jbOP and not saidaN) or (jnbOP and saidaN));
            
            
            
            
            
            
        case currentState is
            when t0 =>
                
            
                     
                sel <= '0';
                cargaREM <= '1';
                nextState <= w1_1;                  --t1 w1_1
---------------------------------------------------------------------------------------------------                
            when t1 =>
                --READ
                cargaRDM <= '1';
                
                mux2 <= '1';
                incPC <= '1';
                nextState <= t2;
---------------------------------------------------------------------------------------------------                
            when t2 =>
                cargaRI <= '1';
                nextState <= t3;
---------------------------------------------------------------------------------------------------        
            when t3 =>
                if (operators or staOP or jmpT) = '1' then
                    sel <= '0';
                    cargaREM <= '1';
                    nextState <= w2_1;                                --t4 w2_1
                    
                elsif (jmpF) = '1' then
                    incPC <= '1';
                    nextState <= t0;
                    
                elsif (hltOP = '1') then
                    nextState <= hlt;
                    
                elsif (notOP <= '1') then
                    selULA <= "0101";
                    cargaACC <= '1';
                    setN <= '1';
                    setZ <= '1';
                    nextState <= t0;
                    
                elsif (rotate <= '1') then
                    
                    if (shrOP <= '1') then
                        selULA <= "1001";
                    
                    elsif (shlOP <= '1') then
                        selULA <= "1000";
                    
                    elsif (rorOP <= '1') then
                        selULA <= "0111";
                    
                    else        --rolOP <= '1'
                        selULA <= "0110";
                    end if;
                    
                    cargaACC <= '1';
                    setC <= '1';
                    setZ <= '1';
                    setN <= '1';
                    nextState <= t0;
                
                else
                    nextState <= t0;        --NOP
                end if;
---------------------------------------------------------------------------------------------------                    
            when t4 =>
                if (operators or staOP) = '1' then
                    --READ
                    cargaRDM <= '1';
                    
                    mux2 <= '1';
                    incPC <= '1';
                    nextState <= t5;
                
                elsif (jmpOP or JmpT) = '1' then
                    --READ
                    cargaRDM <= '1';
                    
                    mux2 <= '1';
                    nextState <= t5;
                
                else
                    nextState <= errorState;
                end if;
---------------------------------------------------------------------------------------------------
            when t5 =>
                if (operators or staOP) = '1' then
                    sel <= '1';
                    cargaREM <= '1';
                    nextState <= w3_1;                        --t6 w3_1
                    
                elsif (jmpOP or jmpT) = '1' then
                    cargaPC <= '1';
                    nextState <= t0;
                
                else
                    nextState <= errorState;
                end if;
---------------------------------------------------------------------------------------------------
            when t6 =>
                if (staOP) = '1' then
                    cargaRDM <= '1';
                    mux2 <= '0';
                    nextState <= t7;
                    
                elsif (operators) <= '1' then
                    --READ
                    cargaRDM <= '1';
                    
                    mux2 <= '1';
                    nextState <= t7;
                
                else
                    nextState <= errorState;
                end if;
---------------------------------------------------------------------------------------------------
            when t7 =>
                if (staOP) = '1' then
                    --WRITE
                    WR <= "1";
                    nextState <= t0;
                    
                elsif (operators) = '1' then
                    if (ldaOP) = '1' then
                        --ULA(Y)
                        selULA <= "1111";
                        cargaACC <= '1';
                        setN <= '1';
                        setZ <= '1';
                    
                    elsif (addOP) = '1' then
                        selULA <= "0001";
                        cargaACC <= '1';
                        setN <= '1';
                        setZ <= '1';
                        setC <= '1';
                        setV <= '1';
                    
                    elsif (subOP) = '1' then
                        selULA <= "0010";
                        cargaACC <= '1';
                        setN <= '1';
                        setZ <= '1';
                        setB <= '1';
                        setV <= '1';
                    
                    elsif (orOP) = '1' then
                        selULA <= "0011";
                        cargaACC <= '1';
                        setN <= '1';
                        setZ <= '1';
                    
                    elsif (andOP) = '1' then
                        selULA <= "0100";
                        cargaACC <= '1';
                        setN <= '1';
                        setZ <= '1';
                    end if;
                    
                    nextState <= t0;
                
                else
                    nextState <= errorState;
                end if;
---------------------------------------------------------------------------------------------------
            when hlt =>               --hlt
                nextState <= currentState;
---------------------------------------------------------------------------------------------------            
            when errorState =>
                err <= "0";
                nextState <= currentState;
---------------------------------------------------------------------------------------------------
--Estados de espera
            when w1_1 =>
                nextState <= w1_2;
            when w1_2 =>
                nextState <= w1_3;
            when w1_3 =>
                nextState <= w1_4;
            when w1_4 =>
                nextState <= t1;
            when w2_1 =>
                nextState <= w2_2;
            when w2_2 =>
                nextState <= w2_3;
            when w2_3 =>
                nextState <= w2_4;
            when w2_4 =>
                nextState <= t4; 
            when w3_1 =>
                nextState <= w3_2;
            when w3_2 =>
                nextState <= w3_3;
            when w3_3 =>
                nextState <= w3_4;
            when w3_4 =>
                nextState <= t6;                                                                       
        end case;
    
    
       
    end process;



--ULA
   ULA: process(saidaACC, saidaRDM, selULA, Cin, tempA, tempS, ula_result,N,Z,C,B,V)
   begin


------CONDIÇOES AQUI
    V <= '0';
    C <= '0';
    B <= '0';
    N <= '0';
    Z <= '0';
    ula_result <= "00000000";
    tempA <= "000000000";
    tempS <= "000000000";


   case selULA is

-------------------------------------------------------------------------------------------
       when "0001" =>           --ADD
           
           tempA <= std_logic_vector(unsigned('0'&saidaACC) + unsigned('0'&saidaRDM));                           --UNSIGNED
           ula_result <= tempA(7 downto 0);
           C <= tempA(8);
           if (saidaACC(7)=saidaRDM(7)) then
               if (saidaACC(7) /= ula_result(7)) then V <= '1';
                   else V <= '0';
               end if;
           else V <= '0';
           end if;
--------------------------------------------------------------------------------------------        
           when "0010" =>       --SUB
           tempS <= std_logic_vector(unsigned('0'&saidaACC) - unsigned('0'&saidaRDM));                           --UNSIGNED
           ula_result <= tempS(7 downto 0);
           B <= tempS(8);
           if (saidaACC(7) /= saidaRDM(7)) then
               if (saidaACC(7) /= ula_result(7)) then V <= '1';
                   else V <= '0';
               end if;
           else V <= '0';
           end if;
-----------------------------------------------------------------------------------------------------
       when "0011" =>           --OR
           ula_result <= saidaACC or saidaRDM;
------------------------------------------------------------------------------------------
       when "0100" =>           --AND
           ula_result <= saidaACC and saidaRDM;
----------------------------------------------------------------------------------------------
       when "0101" =>           --NOT
           ula_result <= not saidaACC;
---------------------------------------------------------------------------------------------
       when "0110" =>           --ROL
           C <= saidaACC(7);
           ula_result(7) <= saidaACC(6);
           ula_result(6) <= saidaACC(5);
           ula_result(5) <= saidaACC(4);
           ula_result(4) <= saidaACC(3);
           ula_result(3) <= saidaACC(2);
           ula_result(2) <= saidaACC(1);
           ula_result(1) <= saidaACC(0);
           ula_result(0) <= Cin;
--------------------------------------------------------------------------------------------
       when "1000" =>           --SHL
           C <= saidaACC(7);
           ula_result(7) <= saidaACC(6);
           ula_result(6) <= saidaACC(5);
           ula_result(5) <= saidaACC(4);
           ula_result(4) <= saidaACC(3);
           ula_result(3) <= saidaACC(2);
           ula_result(2) <= saidaACC(1);
           ula_result(1) <= saidaACC(0);
           ula_result(0) <= '0';
----------------------------------------------------------------------------------------------
       when "0111" =>           --ROR
           C <= saidaACC(0);
           ula_result(0) <= saidaACC(1);
           ula_result(1) <= saidaACC(2);
           ula_result(2) <= saidaACC(3);
           ula_result(3) <= saidaACC(4);
           ula_result(4) <= saidaACC(5);
           ula_result(5) <= saidaACC(6);
           ula_result(6) <= saidaACC(7);
           ula_result(7) <= Cin;
-----------------------------------------------------------------------------------------------
       when "1001" =>           --SHR
           C <= saidaACC(0);
           ula_result(0) <= saidaACC(1);
           ula_result(1) <= saidaACC(2);
           ula_result(2) <= saidaACC(3);
           ula_result(3) <= saidaACC(4);
           ula_result(4) <= saidaACC(5);
           ula_result(5) <= saidaACC(6);
           ula_result(6) <= saidaACC(7);
           ula_result(7) <= '0';
---------------------------------------------------------------------------------------------
        when "1111" =>
            ula_result <= saidaRDM;
---------------------------------------------------------------------------------------------
       when others =>
           ula_result <= "00000000";
           Z <= '0';
           N <= '0';
           C <= '0';
           V <= '0';
           B <= '0';
       end case;
----------------------------------------------------------------------------------------------
       if (ula_result="00000000") then
           Z <= '1'; else Z <= '0';
       end if;
       N <= ula_result(7);
   end process;
--==============================================================================================

    process (clk, rst)
    begin
       if rst = '1' then
           
       elsif (clk'event and clk = '1') then
            if (setV = '1') then
                intV <= V;
            else
                intV <= intV;
            end if;
------------------------------------------            
            if (setC = '1') then
                intC <= C;
            else
                intC <= intC;
             end if;
------------------------------------------               
            if (setB = '1') then
                intB <= B;
            else
                intB <= intB;
            end if;
------------------------------------------            
            if (setN = '1') then
                intN <= N;
            else
                intN <= intN;
            end if;
------------------------------------------            
            if (setZ = '1') then
                intZ <= Z;
            else
                intZ <= intZ;
            end if;
       end if;
    end process;
    
    saidaN <= intN;
    saidaZ <= intZ;
    saidaC <= intC;
    saidaB <= intB;
    saidaV <= intV;

--==============================================================================================

  --PC

  PC: process(clk, rst)
  begin    

      if rst = '1' then
          regPC <= (others => '0');
      elsif (clk'event and clk = '1') then
          if (cargaPC = '1') then
              regPC <= saidaRDM;
          elsif (incPC = '1') then
              regPC <= std_logic_vector(unsigned(regPC) + 1);                   --UNSIGNED
          end if;
      end if;
  end process;
     saidaPC <= regPC;
    
--==============================================================================================

   --ACC

    ACC: process (clk, rst)
   begin
       
      if rst = '1' then
          regACC <= (others => '0');
      elsif (clk'event and clk = '1') then
          if (cargaACC = '1') then
              regACC <= ula_result;
          end if;
      end if;
   end process;
   saidaACC <= regACC;


--==============================================================================================
  
--REM
   REMM: process(clk, rst)
   begin

      if rst = '1' then
          regREM <= (others => '0');
      elsif (clk'event and clk = '1') then
          if (cargaREM = '1') then
              regREM <= entradaREM;
          end if;
      end if;
   end process;
   
   dadoFinal <= regREM;

--=============================================================================================


--RDM
   RDMM: process (clk, rst)
   begin
       
       if rst = '1' then
          regRDM <= (others => '0');
      elsif (clk'event and clk = '1') then
          if (cargaRDM = '1') then
              regRDM <= entradaRDM;
          end if;
      end if;
   end process;
   
   saidaRDM <= regRDM;

--=================================================================================================

--RI
   RII: process (clk, rst)
   begin

       if rst = '1' then
          regRI <= (others => '0');
      elsif (clk'event and clk = '1') then
          if (cargaRI = '1') then
              regRI <= saidaRDM;
          end if;
      end if;
   end process;   
   saidaRI <= regRI;

--=================================================================================================

--MUX
   mux: process (sel, entradaREM, saidaPC, saidaRDM)
   begin
   
    if sel = '0' then
        entradaREM <= saidaPC;
    else
        entradaREM <= saidaRDM; 
    end if;
   end process;
   
   
--MUX2
   mux2k: process (mux2, entradaRDM, saidaACC, dadoSaida)
   begin
   
    if mux2 = '0' then
        entradaRDM <= saidaACC;
    else
        entradaRDM <= dadoSaida;
    end if;
   end process;


--================================================================================================
dadoEntrada <= saidaRDM;

--MEMORIA SEMPRE LENDO = NAO RPECISA DE READ
mem : blk_mem_gen_0
PORT MAP(
    clka => clk,
    wea => WR,
    addra => dadoFinal,               --adress (dadoFinal = End)
    dina => dadoEntrada,             --data in
    douta => dadoSaida               --data out
    --ena => enable
);


end Behavioral;








