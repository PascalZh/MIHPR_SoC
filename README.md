## Naming conventions
### Files
- `***_inst.v` are generated files for megafunction instantiation templates.

### interface
- Take ID for example, `id_reg_io` interface contains just part of the ID registers. For the full list of registers, see the `id_reg.sv` file.

## IF stage
### `bus_if`
The IF bus will check the `stall` when `rdy_` is returned.