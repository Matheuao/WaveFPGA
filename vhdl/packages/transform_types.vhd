-- ============================================================================
--  transform_types.vhd
--
--  Transform types package
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Package for NDWT types.
--
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;

package transform_types is

  -- Versões da transformada NDWT
  type ndwt_transform_optimization is (
    None,
    Shared_multipliers,
    Shared_registers
  );

  type dwt_optimization is (
    DWT_V1,
    DWT_V2
    -- None, etc.
  );

end package transform_types;

package body transform_types is
end package body transform_types;
