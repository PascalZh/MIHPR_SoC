## Naming conventions
### Files
- `***_inst.v` are generated files for megafunction instantiation templates.
### Acronyms
- `epc`, exception program counter, save the pc when entering the exception codes

### interface
- Take ID for example, `id_reg_io` interface contains just part of the ID registers. For the full list of registers, see the `id_reg.sv` file.

## IF stage
### `bus_if`
The IF bus will check the `stall` when `rdy_` is returned.

### `new_pc`
`new_pc` will be set to IF stage registers when `flush` is enabled (when `WRCR`, `EXRT` are executed, or exception occurs).

## WB stage
`dly_flag` is just `br_flag` from ID stage.