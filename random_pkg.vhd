-------------------------------------------------------------------------------
--
--  A collection of utilities related to random-value generation.
--
--  This file is part of the noasic library.
--
--  Usage:
--    use work.random_pkg.all;
--    ...
--    i := randint(min => 0, max => 1023); -- generate a random integer in range [0..1023]
--    ... 
--    randwait(clk => s_clk, min => 0, max => 5); -- wait for [0..5] clock cycles
--
--  Author(s):
--    Guy Eschemann, Guy.Eschemann@gmail.com
--
-------------------------------------------------------------------------------
--
--  Copyright (c) 2012 Guy Eschemann
--
--  This source file may be used and distributed without restriction provided
--  that this copyright statement is not removed from the file and that any
--  derivative work contains the original copyright notice and the associated
--  disclaimer.
--
--  This source file is free software: you can redistribute it and/or modify it
--  under the terms of the GNU Lesser General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or (at your
--  option) any later version.
--
--  This source file is distributed in the hope that it will be useful, but
--  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
--  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
--  for more details.
--
--  You should have received a copy of the GNU Lesser General Public License
--  along with the noasic library.  If not, see http://www.gnu.org/licenses
--
-------------------------------------------------------------------------------

library ieee;

use ieee.std_logic_1164.all;
use ieee.math_real.all;

package random_pkg is

  -- Returns a random integer in the range [min, max]
  impure function randint(min : integer; max : integer) return integer;

  -- Waits for a random number of clock cycles
  procedure randwait(signal clk : in std_logic; min, max : in natural);

end package random_pkg;

package body random_pkg is
  type t_random is protected
    -- Returns a random integer in the range [min, max]
    impure function randint(min : integer; max : integer) return integer;
  end protected;

  type t_random is protected body
    variable v_seed_1, v_seed_2 : positive := 1;
    impure function randint(min : integer; max : integer) return integer is
      variable v_rand_real : real;
      variable v_rand_int  : integer;
    begin
      assert max >= min severity failure;
      uniform(v_seed_1, v_seed_2, v_rand_real);
      v_rand_int := min + integer(real(max - min) * v_rand_real);
      assert v_rand_int >= min and v_rand_int <= max severity failure;
      return v_rand_int;
    end function;
  end protected body;

  shared variable random : t_random;

  impure function randint(min : integer; max : integer) return integer is
  begin
    return random.randint(min, max);
  end function;

  procedure randwait(signal clk : in std_logic; min, max : in natural) is
    variable v_cycles : natural;
  begin
    assert max >= min severity failure;
    v_cycles := randint(min, max);
    for i in 1 to v_cycles loop
      wait until rising_edge(clk);
    end loop;
  end procedure;

end package body random_pkg;
