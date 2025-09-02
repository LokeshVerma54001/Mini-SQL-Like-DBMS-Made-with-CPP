#ifndef GLOBALS_H
#define GLOBALS_H

#define MAX_TABLES 10
#define MAX_COLS 10
#define MAX_ROWS 100
#define MAX_NAME_LEN 50
#define MAX_VALUE_LEN 50

// Table structure
struct Table {
    char name[MAX_NAME_LEN];
    char columns[MAX_COLS][MAX_NAME_LEN];   // use this field name
    int col_count;
    char rows[MAX_ROWS][MAX_COLS][MAX_VALUE_LEN];
    int row_count;
};

// Extern declarations (defined in file_IO.cpp)
extern Table tables[MAX_TABLES];
extern int table_count;

// Temporary buffers used during CREATE/INSERT parsing
extern char col_list[MAX_COLS][MAX_NAME_LEN];
extern int col_count;

extern char value_list_values[MAX_COLS][MAX_VALUE_LEN];
extern int value_list_count;

#endif
