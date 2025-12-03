////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include "bsp.h"

//#define SIM_ALL_ZERO							1
#define SIM_NO_CONSECUTIVE_1					1

int find_rows_with_longest_ones(int rows, int cols, int arr[rows][cols], int result[rows][1])
{
    int max_consecutive = 0; // Length of the longest sequence of 1s
    int found_one = 0;       // Flag to check if any 1 is found in the array

    // First pass: Find the maximum consecutive 1s
    for (int i = 0; i < rows; i++) {
        int current_consecutive = 0; // Current count of consecutive 1s
        int max_in_row = 0;          // Maximum consecutive 1s in the current row

        for (int j = 0; j < cols; j++) {
            if (arr[i][j] == 1) {
                current_consecutive++;
                if (current_consecutive > max_in_row) {
                    max_in_row = current_consecutive;
                }
                found_one = 1; // At least one 1 is found
            } else {
                current_consecutive = 0; // Reset the count if a 0 is encountered
            }
        }

        // Update the overall maximum if the current row has a longer sequence
        if (max_in_row > max_consecutive) {
            max_consecutive = max_in_row;
        }
    }

    // If no 1s were found in the entire array, return -1
    if (!found_one) {
        return -1;
    }

    // Second pass: Populate the result array
    for (int i = 0; i < rows; i++) {
        int current_consecutive = 0; // Current count of consecutive 1s
        int max_in_row = 0;          // Maximum consecutive 1s in the current row

        for (int j = 0; j < cols; j++) {
            if (arr[i][j] == 1) {
                current_consecutive++;
                if (current_consecutive > max_in_row) {
                    max_in_row = current_consecutive;
                }
            } else {
                current_consecutive = 0; // Reset the count if a 0 is encountered
            }
        }

        // Set the result array
        if (max_in_row == max_consecutive) {
            result[i][0] = 1; // Row has the maximum consecutive 1s
        } else {
            result[i][0] = 0; // Row does not have the maximum consecutive 1s
        }
    }

    return 0; // Success
}

int find_center_row(int rows, int result[rows][1])
{
    int max_length = 0;       // Length of the longest sequence of consecutive 1s
    int max_start = -1;       // Start index of the longest sequence
    int max_end = -1;         // End index of the longest sequence

    int current_length = 0;   // Length of the current sequence of consecutive 1s
    int current_start = -1;   // Start index of the current sequence

    for (int i = 0; i < rows; i++) {
        if (result[i][0] == 1) {
            if (current_length == 0) {
                current_start = i; // Start of a new sequence
            }
            current_length++;
        } else {
            if (current_length > max_length) {
                max_length = current_length;
                max_start = current_start;
                max_end = i - 1;
            }
            current_length = 0; // Reset the current sequence
        }
    }

    // Check the last sequence
    if (current_length > max_length) {
        max_length = current_length;
        max_start = current_start;
        max_end = rows - 1;
    }

    // Calculate the center row
    if (max_start != -1 && max_end != -1) {
        if (max_length % 2 == 0) {
            // If the length is even, return the row before the center point
            return (max_start + max_end) / 2;
        } else {
            // If the length is odd, return the middle row
            return (max_start + max_end) / 2;
        }
    }

    return -1; // No sequence of 1s found
}

int find_center_of_row(int row, int cols, int arr[cols])
{
    int max_length = 0;       // Length of the longest sequence of consecutive 1s
    int max_start = -1;       // Start index of the longest sequence
    int max_end = -1;         // End index of the longest sequence

    int current_length = 0;   // Length of the current sequence of consecutive 1s
    int current_start = -1;   // Start index of the current sequence

    for (int j = 0; j < cols; j++) {
        if (arr[j] == 1) {
            if (current_length == 0) {
                current_start = j; // Start of a new sequence
            }
            current_length++;
        } else {
            if (current_length > max_length) {
                max_length = current_length;
                max_start = current_start;
                max_end = j - 1;
            }
            current_length = 0; // Reset the current sequence
        }
    }

    // Check the last sequence
    if (current_length > max_length) {
        max_length = current_length;
        max_start = current_start;
        max_end = cols - 1;
    }

    // Calculate the center column
    if (max_start != -1 && max_end != -1) {
        if (max_length % 2 == 0) {
            // If the length is even, return the column before the center point
            return (max_start + max_end) / 2;
        } else {
            // If the length is odd, return the middle column
            return (max_start + max_end) / 2;
        }
    }

    return -1; // No sequence of 1s found
}

int test_tuning_algo(void)
{
    int rows = 6; // Number of rows
    int cols = 8; // Number of columns

#ifdef SIM_ALL_ZERO
    int arr[6][8] = {
    		{0, 0, 0, 0, 0, 0, 0, 0},
    		{0, 0, 0, 0, 0, 0, 0, 0},
    		{0, 0, 0, 0, 0, 0, 0, 0},
    		{0, 0, 0, 0, 0, 0, 0, 0},
    		{0, 0, 0, 0, 0, 0, 0, 0},
    		{0, 0, 0, 0, 0, 0, 0, 0},
    };
#elif SIM_NO_CONSECUTIVE_1
    int arr[6][8] = {
    		{0, 1, 0, 1, 0, 1, 0, 1},
    		{0, 0, 0, 0, 0, 0, 0, 0},
    		{1, 0, 0, 1, 0, 0, 1, 0},
    		{0, 0, 0, 0, 0, 0, 0, 0},
    		{0, 0, 1, 0, 0, 0, 0, 1},
    		{0, 0, 0, 0, 0, 0, 0, 0},
    };
#else
    int arr[6][8] = {
    		{0, 0, 1, 1, 1, 0, 0, 0},
    		{1, 1, 1, 1, 0, 0, 0, 0},
    		{0, 0, 0, 1, 1, 1, 1, 0},
    		{0, 1, 1, 1, 1, 1, 0, 0},
    		{0, 0, 0, 0, 1, 1, 1, 1},
    		{1, 1, 1, 1, 1, 0, 0, 0}
    };
#endif

	bsp_printf_full("Test map:\r\n");
	for (int i = 0; i < rows; i++) {
		for (int j = 0; j < cols; j++) {
			bsp_printf_full("%d ", arr[i][j]);
		}
		bsp_printf_full("\r\n");
	}

    // Step 1: Find rows with the longest consecutive 1s
    int result[rows][1];
    int ret = 0;

    ret = find_rows_with_longest_ones(rows, cols, arr, result);

    if (ret) {
    	bsp_printf_full("There is zero '1' in the entire array\r\n");
    	return -1;
    }

    // Print the result array
    bsp_printf_full("Result array:\r\n");
    for (int i = 0; i < rows; i++) {
        bsp_printf_full("%d\r\n", result[i][0]);
    }

    // Step 2: Find the center row of the result array
    int center_row = find_center_row(rows, result);

    if (center_row != -1) {
    	bsp_printf_full("Center row of the maximum consecutive 1s: %d\r\n", center_row);

        // Step 3: Find the center of the longest consecutive 1s in the original array
        int center_col = find_center_of_row(center_row, cols, arr[center_row]);

        if (center_col != -1) {
        	bsp_printf_full("Center column of the longest consecutive 1s in row %d: %d\r\n", center_row, center_col);
        } else {
        	bsp_printf_full("No sequence of 1s found in row %d.\r\n", center_row);
        }
    } else {
    	bsp_printf_full("No sequence of 1s found.\r\n");
    }

    return 0;
}


