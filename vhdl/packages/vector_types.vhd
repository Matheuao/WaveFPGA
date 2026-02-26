-- ============================================================================
--  vector_types.vhd
--
--  Vector types package
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Package for vector signal description types.
--
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================

library ieee;
use ieee.numeric_std.all;

package vector_types is
  type signed_vector is array (natural range <>) of signed;
  
end package vector_types;


package body vector_types is
end package body vector_types;
