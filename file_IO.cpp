#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>   // for mkdir
#include <sys/types.h>
#include "globals.h"
#include "file_IO.h"

// ===== Define extern globals here =====
Table tables[MAX_TABLES];
int table_count = 0;

char col_list[MAX_COLS][MAX_NAME_LEN];
int col_count = 0;

char value_list_values[MAX_COLS][MAX_VALUE_LEN];
int value_list_count = 0;
// =====================================

void save_tables() {
    // Ensure "tables" directory exists
    #ifdef _WIN32
        _mkdir("tables");
    #else
        mkdir("tables", 0755);
    #endif

    for (int t = 0; t < table_count; t++) {
        char filename[256];
        snprintf(filename, sizeof(filename), "tables/%s.tbl", tables[t].name);
        FILE *f = fopen(filename, "w");
        if (!f) continue;

        // Save column count + names
        fprintf(f, "%d\n", tables[t].col_count);
        for (int c = 0; c < tables[t].col_count; c++)
            fprintf(f, "%s\n", tables[t].columns[c]);

        // Save rows
        fprintf(f, "%d\n", tables[t].row_count);
        for (int r = 0; r < tables[t].row_count; r++) {
            for (int c = 0; c < tables[t].col_count; c++) {
                fprintf(f, "%s", tables[t].rows[r][c]);
                if (c < tables[t].col_count - 1) fprintf(f, ",");
            }
            fprintf(f, "\n");
        }
        fclose(f);
    }
}

static void strip_newline(char *s) {
    s[strcspn(s, "\n")] = 0;
}

// filename like "tables/students.tbl"
void load_table(const char *filepath) {
    FILE *f = fopen(filepath, "r");
    if (!f) return;
    if (table_count >= MAX_TABLES) {
        fclose(f);
        return;
    }

    Table *t = &tables[table_count];

    // derive table name (strip directory + ".tbl")
    const char *basename = strrchr(filepath, '/');
    if (!basename) basename = filepath;
    else basename++;  // skip '/'

    size_t len = strlen(basename);
    size_t base = (len >= 4) ? len - 4 : len;
    if (base >= MAX_NAME_LEN) base = MAX_NAME_LEN - 1;
    memcpy(t->name, basename, base);
    t->name[base] = '\0';

    // columns
    if (fscanf(f, "%d\n", &t->col_count) != 1) { fclose(f); return; }
    for (int c = 0; c < t->col_count; c++) {
        if (!fgets(t->columns[c], MAX_NAME_LEN, f)) { fclose(f); return; }
        strip_newline(t->columns[c]);
    }

    // rows
    if (fscanf(f, "%d\n", &t->row_count) != 1) { fclose(f); return; }
    for (int r = 0; r < t->row_count; r++) {
        char line[1024];
        if (!fgets(line, sizeof(line), f)) { fclose(f); return; }
        strip_newline(line);

        char *tok = strtok(line, ",");
        int c = 0;
        while (tok && c < t->col_count) {
            strncpy(t->rows[r][c], tok, MAX_VALUE_LEN - 1);
            t->rows[r][c][MAX_VALUE_LEN - 1] = '\0';
            tok = strtok(NULL, ",");
            c++;
        }
    }

    table_count++;
    fclose(f);
}

void load_all_tables() {
    DIR *dir = opendir("tables");
    if (!dir) return;
    struct dirent *entry;

    while ((entry = readdir(dir))) {
        const char *name = entry->d_name;
        size_t len = strlen(name);
        if (len >= 4 && strcmp(name + (len - 4), ".tbl") == 0) {
            char filepath[256];
            snprintf(filepath, sizeof(filepath), "tables/%s", name);
            load_table(filepath);
        }
    }
    closedir(dir);
}
