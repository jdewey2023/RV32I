    .section .text
    .globl _start

_start:
    # Setup constants
    lui s0, 0x10010       # s0 = board base address (0x10010000)
    addi s1, x0, 4        # s1 = n = 4
    addi s2, x0, 0        # s2 = row = 0

    jal ra, solve

hang:
    jal x0, hang          # Infinite loop

# -------------------------------------
# solve(row) — s2 = row, s0 = board base, s1 = n
solve:
    beq s2, s1, solve_ret

    addi t0, x0, 0        # t0 = col = 0
solve_col_loop:
    bge t0, s1, solve_ret

    addi a0, s2, 0        # a0 = row
    addi a1, t0, 0        # a1 = col
    jal ra, is_valid
    beq a0, x0, invalid

    slli t1, s2, 2        # t1 = row * 4
    add t1, t1, s0        # board address
    sw t0, 0(t1)          # board[row] = col

    addi s2, s2, 1
    jal ra, solve
    addi s2, s2, -1       # backtrack

invalid:
    addi t0, t0, 1
    jal x0, solve_col_loop

solve_ret:
    jalr x0, 0(ra)

# -------------------------------------
# is_valid(row, col)
# a0 = row, a1 = col
# returns a0 = 1 (valid) or 0 (invalid)
is_valid:
    addi t0, x0, 0        # i = 0

valid_loop:
    bge t0, a0, valid_done

    slli t1, t0, 2
    add t1, t1, s0
    lw t2, 0(t1)          # t2 = board[i]

    beq t2, a1, invalid_pos

    sub t3, t2, a1
    blt t3, x0, dx_neg
    addi t4, t3, 0
    jal x0, dx_done

dx_neg:
    sub t4, x0, t3

dx_done:
    sub t5, t0, a0
    blt t5, x0, dy_neg
    addi t6, t5, 0
    jal x0, dy_done

dy_neg:
    sub t6, x0, t5

dy_done:
    beq t4, t6, invalid_pos

    addi t0, t0, 1
    jal x0, valid_loop

invalid_pos:
    addi a0, x0, 0
    jalr x0, 0(ra)

valid_done:
    addi a0, x0, 1
    jalr x0, 0(ra)
