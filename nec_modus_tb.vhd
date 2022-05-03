--Test bench for QPSK modulation
--This code was written in Xilinx ISE 14.7 condition.
library ieee;
library synopsys;
library std;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use ieee.numeric_bit.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use std.standard.all;
use synopsys.arithmetic.all;
use synopsys.attributes.all;
use synopsys.types.all;

entity tb_nec_modus is
    --port(
	--s : in std_logic_vector(5 downto 0); --Count signal from 0 to 32
    --c : in std_logic_vector(9 downto 0); --from 0 to 273 
    --valid : out std_logic_vector(12 downto 0); --FFF hexadecimal value
	--Exp : out std_logic_vector(5 downto 0); --13
	--I: out std_logic_vector(13 downto 0); -- Modulation Amplitude I-phase
	--Q : out std_logic_vector(13 downto 0)); -- Modulation Amplitude Q-phase
end tb_nec_modus;
 
architecture RTL of tb_nec_modus is 
   --Input signals
   signal s_s : std_logic_vector(5 downto 0);-- 's' signal indication for on waveform
   signal c_s : std_logic_vector(9 downto 0);-- 'c' signal indication for on waveform
  --Output signals
   signal valid_s : string(4 downto 1);--'valid' signal indication for on waveform in string form
   signal Exp_s : std_logic_vector(5 downto 0);-- 'Exp' signal indication for on waveform
   signal I_s : std_logic_vector(13 downto 0);--I phase
   signal Q_s : std_logic_vector(13 downto 0);--Q phase
   signal ch_s : character; --first letter indication for on waveform
   signal valid_vec : std_logic_vector(11 downto 0); --'valid' signal indication for on waveform in logic vector form
   file input_text : text; --open read_mode is "nec_modus.txt";
	function pow(b : integer; p : integer) return integer is
	--Function peforms mathematical exponent operation
	 variable v : integer := b;
	 variable cpy : integer;
	 variable i : integer := 1;
    begin
		while i < p loop
		v := v * cpy;
		i := i + 1;
		end loop;
    return v;
   end function; 
	function table(h : character) return integer is
	--Function for character to decimal conversion LUT
	 variable d : integer ;
    begin
		case h is
		when '0' => d := 0;
		when '1' => d := 1;
		when '2' => d := 2;
		when '3' => d := 3;
		when '4' => d := 4;
		when '5' => d := 5;
		when '6' => d := 6;
		when '7' => d := 7;
		when '8' => d := 8;
		when '9' => d := 9;
		when 'A' => d := 10;
		when 'B' => d := 11;
		when 'C' => d := 12;
		when 'D' => d := 13;
		when 'E' => d := 14;
		when 'F' => d := 15;
		when 'a' => d := 10;
		when 'b' => d := 11;
		when 'c' => d := 12;
		when 'd' => d := 13;
		when 'e' => d := 14;
		when 'f' => d := 15;
		end case;
    return d;
   end function;
	impure function hexstr2dec(str : string) return integer is
	--Function for Hex string to decimal conversion by one click along with LUT method above
    variable tmp1 : integer;
	 variable tmp2 : integer;
	 variable tmp3 : integer;
	 variable deci1 : integer;
	 variable deci2 : integer;
	 variable deci3 : integer;
	 variable token : integer;
	 variable fin : integer;
    begin
	 token := 1;
	 case token is
	 when 1 =>
		tmp1 := table(str(1));
		tmp2 := table(str(2));
		tmp3 := table(str(3));
		token := 2;
	when 2 =>
		deci1 := pow(tmp1,1);
		deci2 := pow(tmp2,2);
		deci3 := pow(tmp3,3);
		fin := deci1 + deci2 + deci3;
	end case;
    return fin; -- The result will be 4094 rather than 4095, even if adds one into it to make 4095 then it will turn into1, assumed due to overflow
   end function;
begin
	process is
		variable text_line : line; --Text buffer for one sentence length
		variable s_v : integer := 0;
		variable c_v : integer; -- buffer data to substitute
		variable valid_v : string(4 downto 1);--buffer to subs in string
		variable Exp_v : integer := 0;--buffer to subs
		variable I_v : integer;--buffer to subs
		variable Q_v : integer;--buffer to subs
		variable cnt : integer; -- packet transmission counting var
		variable ch_v : character; --buffer for 'W' but no meaning
		begin
		file_open (input_text, "nec_modus.txt", read_mode); --imports text file from directory, text file should be located in work folder
		while not endfile(input_text) loop -- Infinite loop until reached at the end
			readline(input_text, text_line); -- Reads one entire sentence of file
			-- Skip empty lines and single-line comments
			if text_line.all'length = 0 or text_line.all(1) = '#' then
				next; --Skips when commenting letters were captured.
			end if;
			--<string_type> :: S			
			--<string_type> :: Exp | I | Q | V | C		
				read(text_line, ch_v); --Reads first letter 'S' or 'W'
				ch_s <= ch_v; --Assignemnt has no meaning just padding
				read(text_line, Exp_v);  --Reads 13
				read(text_line, I_v);  --Reads modulation amplitude for I
				read(text_line, Q_v);  --Reads modulation amplitude for Q
				read(text_line, valid_v); --Reads hexadicmal in string; ModelSim & Xilinx ISE do not support 'hread()'
				read(text_line, c_v); --Reads counting number of packet transmission 
				I_s <=  conv_std_logic_vector(I_v,I_s'length); -- Subs modulation amplitude for I
				Q_s <=  conv_std_logic_vector(Q_v,Q_s'length); -- Subs modulation amplitude for Q
				valid_s <= valid_v; -- Subs FFF in string form to express as it was
				valid_vec <= conv_std_logic_vector(hexstr2dec(valid_v),valid_vec'length); -- Subs FFF in binary form
				c_s <=  conv_std_logic_vector(c_v,c_s'length); -- Subs packet transmission counting number
				cnt := c_v + 1;
				if ch_v = 'S' then
				ch_s <= ch_v;
				s_s <=  conv_std_logic_vector(Exp_v,s_s'length); --Subs global count when 'S' in a sentence was detected
				next;
				else
				Exp_s <= conv_std_logic_vector(Exp_v,Exp_s'length); --Subs 13 into Exp when 'W' in a sentence was detected
				end if; --text line if
		wait for 5 ns;
	end loop; --End of loop for continuous reading.
	file_close(input_text);
	end process;
end architecture RTL;
