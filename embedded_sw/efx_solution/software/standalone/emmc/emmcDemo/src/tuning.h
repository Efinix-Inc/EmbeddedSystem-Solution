////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef SRC_TUNING_H_
#define SRC_TUNING_H_

int find_rows_with_longest_ones(int rows, int cols, int arr[rows][cols], int result[rows][1]);
int find_center_row(int rows, int result[rows][1]);
int find_center_of_row(int row, int cols, int arr[cols]);
int test_tuning_algo(void);

#endif /* SRC_TUNING_H_ */
