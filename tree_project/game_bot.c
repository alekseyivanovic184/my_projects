// DO NOT MODIFY eval_game_state FUNCTION

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "connect4.h"
#include "game_bot.h"
#include <limits.h>

void eval_game_state(GameState *gs)
{
    GameStatus status = get_game_status(gs);
    if (status == PLAYER_1_WIN)
    {
        gs->evaluation = 1000;
        return;
    }
    else if (status == PLAYER_2_WIN)
    {
        gs->evaluation = -1000;
        return;
    }
    else if (status == DRAW)
    {
        gs->evaluation = 0;
        return;
    }

    // Count the number of 3s in a row
    int player_1_3 = 0;
    int player_2_3 = 0;

    // Count the number of 2s in a row with an extra space around
    int player_1_2 = 0;
    int player_2_2 = 0;

    // Check horizontal
    for (int i = 0; i < gs->height; i++)
    {
        for (int j = 0; j <= gs->width - 3; j++)
        {
            int index = i * gs->width + j;

            int x_count = (gs->board[index] == 'X') + (gs->board[index + 1] == 'X') + (gs->board[index + 2] == 'X');
            int o_count = (gs->board[index] == 'O') + (gs->board[index + 1] == 'O') + (gs->board[index + 2] == 'O');
            int empty_count = (gs->board[index] == '_') + (gs->board[index + 1] == '_') + (gs->board[index + 2] == '_');

            if (x_count == 3)
                player_1_3++;
            else if (o_count == 3)
                player_2_3++;
            else if (x_count == 2 && empty_count == 1)
                player_1_2++;
            else if (o_count == 2 && empty_count == 1)
                player_2_2++;
        }
    }

    // Check vertical
    for (int i = 0; i <= gs->height - 3; i++)
    {
        for (int j = 0; j < gs->width; j++)
        {
            int index = i * gs->width + j;
            // if (gs->board[index] != '_' &&
            //     gs->board[index] == gs->board[index + gs->width] &&
            //     gs->board[index] == gs->board[index + 2 * gs->width])
            // {
            //     if (gs->board[index] == 'X')
            //         player_1_3++;
            //     else
            //         player_2_3++;
            // }

            int x_count = (gs->board[index] == 'X') + (gs->board[index + gs->width] == 'X') + (gs->board[index + 2 * gs->width] == 'X');
            int o_count = (gs->board[index] == 'O') + (gs->board[index + gs->width] == 'O') + (gs->board[index + 2 * gs->width] == 'O');
            int empty_count = (gs->board[index] == '_') + (gs->board[index + gs->width] == '_') + (gs->board[index + 2 * gs->width] == '_');

            if (x_count == 3)
                player_1_3++;
            else if (o_count == 3)
                player_2_3++;
            else if (x_count == 2 && empty_count == 1)
                player_1_2++;
            else if (o_count == 2 && empty_count == 1)
                player_2_2++;
        }
    }

    // Check diagonal (top-left to bottom-right)
    for (int i = 0; i <= gs->height - 3; i++)
    {
        for (int j = 0; j <= gs->width - 3; j++)
        {
            int index = i * gs->width + j;
            // if (gs->board[index] != '_' &&
            //     gs->board[index] == gs->board[index + gs->width + 1] &&
            //     gs->board[index] == gs->board[index + 2 * gs->width + 2])
            // {
            //     if (gs->board[index] == 'X')
            //         player_1_3++;
            //     else
            //         player_2_3++;
            // }

            int x_count = (gs->board[index] == 'X') + (gs->board[index + gs->width + 1] == 'X') + (gs->board[index + 2 * gs->width + 2] == 'X');
            int o_count = (gs->board[index] == 'O') + (gs->board[index + gs->width + 1] == 'O') + (gs->board[index + 2 * gs->width + 2] == 'O');
            int empty_count = (gs->board[index] == '_') + (gs->board[index + gs->width + 1] == '_') + (gs->board[index + 2 * gs->width + 2] == '_');

            if (x_count == 3)
                player_1_3++;
            else if (o_count == 3)
                player_2_3++;
            else if (x_count == 2 && empty_count == 1)
                player_1_2++;
            else if (o_count == 2 && empty_count == 1)
                player_2_2++;
        }
    }

    // Check diagonal (top-right to bottom-left)
    for (int i = 0; i <= gs->height - 4; i++)
    {
        for (int j = gs->width - 1; j >= 2; j--)
        {
            int index = i * gs->width + j;
            // if (gs->board[index] != '_' &&
            //     gs->board[index] == gs->board[index + gs->width - 1] &&
            //     gs->board[index] == gs->board[index + 2 * gs->width - 2])
            // {
            //     if (gs->board[index] == 'X')
            //         player_1_3++;
            //     else
            //         player_2_3++;
            // }

            int x_count = (gs->board[index] == 'X') + (gs->board[index + gs->width - 1] == 'X') + (gs->board[index + 2 * gs->width - 2] == 'X');
            int o_count = (gs->board[index] == 'O') + (gs->board[index + gs->width - 1] == 'O') + (gs->board[index + 2 * gs->width - 2] == 'O');
            int empty_count = (gs->board[index] == '_') + (gs->board[index + gs->width - 1] == '_') + (gs->board[index + 2 * gs->width - 2] == '_');

            if (x_count == 3)
                player_1_3++;
            else if (o_count == 3)
                player_2_3++;
            else if (x_count == 2 && empty_count == 1)
                player_1_2++;
            else if (o_count == 2 && empty_count == 1)
                player_2_2++;
        }
    }

    gs->evaluation = 10 * (player_1_3 - player_2_3) + 3 * (player_1_2 - player_2_2);
}

int get_max(TreeNode *Node) {
    if (Node->num_children == 0 || Node->num_children == -1) {
        eval_game_state(Node->game_state);
        return Node->game_state->evaluation;
    }
    int max_value = INT_MIN;

    for (int i = 0; i < Node->num_children; i++) {
        int child_score = get_min(Node->children[i]);
        
        if (child_score > max_value) {
            max_value = child_score;
        }

    }

    return max_value;
}

int get_min(TreeNode *Node) {
    
    if (Node->num_children == 0 || Node->num_children == -1) {
        eval_game_state(Node->game_state);
        return Node->game_state->evaluation;
    }
    int min_value = INT_MAX;
    for (int i = 0; i < Node->num_children; i++) {
        int child_score = get_max(Node->children[i]);
    
        if (child_score < min_value) {
            min_value = child_score;
        }
    }

    return min_value;
}

void eval_game_tree(TreeNode *root){
    
    if (root == NULL)
    {
        return;
    }
    if (root->num_children == -1 || root->num_children == 0)
    {
        eval_game_state(root->game_state);

    }else{
        for (int i = 0; i < root->num_children; i++)
        {
            eval_game_tree(root->children[i]);
        }

    }

}


int best_move(TreeNode *root) {
    
    eval_game_tree(root); // Öncelikle oyun ağacını değerlendir

    int best_index = -1; 
    int best_score;
    
    // Maximizer mi yoksa Minimizer mı olduğumuzu kontrol et
    if (root->game_state->next_turn == false) {
        best_score = INT_MIN;
        for (int i = 0; i < root->num_children; i++) {
            int temp_score = get_min(root->children[i]);
            if (temp_score > best_score) {
                best_score = temp_score;
                best_index = i; 
            }
        }
    } else {
        // Minimizer
        best_score = INT_MAX;
        for (int i = 0; i < root->num_children; i++) {
            int temp_score = get_max(root->children[i]);
            if (temp_score < best_score) {
                best_score = temp_score;
                best_index = i; // En iyi skoru sağlayan çocuğun indeksini güncelle
            }
        }
    }

    return best_index; // En iyi hamlenin indeksini döndür
}

// DO NOT MODIFY eval_game_state FUNCTION
/*#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#include "connect4.h"
#include "game_bot.h"

void eval_game_state(GameState *gs)
{
    GameStatus status = get_game_status(gs);
    if (status == PLAYER_1_WIN)
    {
        gs->evaluation = 1000;
        return;
    }
    else if (status == PLAYER_2_WIN)
    {
        gs->evaluation = -1000;
        return;
    }
    else if (status == DRAW)
    {
        gs->evaluation = 0;
        return;
    }

    // Count the number of 3s in a row
    int player_1_3 = 0;
    int player_2_3 = 0;

    // Count the number of 2s in a row with an extra space around
    int player_1_2 = 0;
    int player_2_2 = 0;

    // Check horizontal
    for (int i = 0; i < gs->height; i++)
    {
        for (int j = 0; j <= gs->width - 3; j++)
        {
            int index = i * gs->width + j;

            int x_count = (gs->board[index] == 'X') + (gs->board[index + 1] == 'X') + (gs->board[index + 2] == 'X');
            int o_count = (gs->board[index] == 'O') + (gs->board[index + 1] == 'O') + (gs->board[index + 2] == 'O');
            int empty_count = (gs->board[index] ==' ') + (gs->board[index + 1] ==' ') + (gs->board[index + 2] == '_');

            if (x_count == 3)
                player_1_3++;
            else if (o_count == 3)
                player_2_3++;
            else if (x_count == 2 && empty_count == 1)
                player_1_2++;
            else if (o_count == 2 && empty_count == 1)
                player_2_2++;
        }
    }

    // Check vertical
    for (int i = 0; i <= gs->height - 3; i++)
    {
        for (int j = 0; j < gs->width; j++)
        {
            int index = i * gs->width + j;
            // if (gs->board[index] != '_' &&
            //     gs->board[index] == gs->board[index + gs->width] &&
            //     gs->board[index] == gs->board[index + 2 * gs->width])
            // {
            //     if (gs->board[index] == 'X')
            //         player_1_3++;
            //     else
            //         player_2_3++;
            // }

            int x_count = (gs->board[index] == 'X') + (gs->board[index + gs->width] == 'X') + (gs->board[index + 2 * gs->width] == 'X');
            int o_count = (gs->board[index] == 'O') + (gs->board[index + gs->width] == 'O') + (gs->board[index + 2 * gs->width] == 'O');
            int empty_count = (gs->board[index] ==' ') + (gs->board[index + gs->width] ==' ') + (gs->board[index + 2 * gs->width] == '_');

            if (x_count == 3)
                player_1_3++;
            else if (o_count == 3)
                player_2_3++;
            else if (x_count == 2 && empty_count == 1)
                player_1_2++;
            else if (o_count == 2 && empty_count == 1)
                player_2_2++;
        }
    }

    // Check diagonal (top-left to bottom-right)
    for (int i = 0; i <= gs->height - 3; i++)
    {
        for (int j = 0; j <= gs->width - 3; j++)
        {
            int index = i * gs->width + j;
            // if (gs->board[index] != '_' &&
            //     gs->board[index] == gs->board[index + gs->width + 1] &&
            //     gs->board[index] == gs->board[index + 2 * gs->width + 2])
            // {
            //     if (gs->board[index] == 'X')
            //         player_1_3++;
            //     else
            //         player_2_3++;
            // }

            int x_count = (gs->board[index] == 'X') + (gs->board[index + gs->width + 1] == 'X') + (gs->board[index + 2 * gs->width + 2] == 'X');
            int o_count = (gs->board[index] == 'O') + (gs->board[index + gs->width + 1] == 'O') + (gs->board[index + 2 * gs->width + 2] == 'O');
            int empty_count = (gs->board[index] ==' ') + (gs->board[index + gs->width + 1] ==' ') + (gs->board[index + 2 * gs->width + 2] == '_');

            if (x_count == 3)
                player_1_3++;
            else if (o_count == 3)
                player_2_3++;
            else if (x_count == 2 && empty_count == 1)
                player_1_2++;
            else if (o_count == 2 && empty_count == 1)
                player_2_2++;
        }
    }

    // Check diagonal (top-right to bottom-left)
    for (int i = 0; i <= gs->height - 4; i++)
    {
        for (int j = gs->width - 1; j >= 2; j--)
        {
            int index = i * gs->width + j;
            // if (gs->board[index] != '_' &&
            //     gs->board[index] == gs->board[index + gs->width - 1] &&
            //     gs->board[index] == gs->board[index + 2 * gs->width - 2])
            // {
            //     if (gs->board[index] == 'X')
            //         player_1_3++;
            //     else
            //         player_2_3++;
            // }

            int x_count = (gs->board[index] == 'X') + (gs->board[index + gs->width - 1] == 'X') + (gs->board[index + 2 * gs->width - 2] == 'X');
            int o_count = (gs->board[index] == 'O') + (gs->board[index + gs->width - 1] == 'O') + (gs->board[index + 2 * gs->width - 2] == 'O');
            int empty_count = (gs->board[index] ==' ') + (gs->board[index + gs->width - 1] ==' ') + (gs->board[index + 2 * gs->width - 2] == '_');

            if (x_count == 3)
                player_1_3++;
            else if (o_count == 3)
                player_2_3++;
            else if (x_count == 2 && empty_count == 1)
                player_1_2++;
            else if (o_count == 2 && empty_count == 1)
                player_2_2++;
        }
    }

    gs->evaluation = 10 * (player_1_3 - player_2_3) + 3 * (player_1_2 - player_2_2);

}

// Given a root node, evaluate all the leaf nodes using eval_game_state function
void eval_game_tree(TreeNode *root){
    
    if (!root)
    {
        return;
    }
    if (root->num_children == -1 || root->num_children == 0)
    {
        eval_game_state(root->game_state);
       
    }else{
        for (int i = 0; i < root->num_children; i++)
        {
            eval_game_tree(root->children[i]);
        }
        
    }
    

   
    
}




int best_move(TreeNode *root) {
    eval_game_tree(root); // Öncelikle oyun ağacını değerlendir

    int best_index = -1; 
    int best_score;
    
    // Maximizer mi yoksa Minimizer mı olduğumuzu kontrol et
    if (root->game_state->next_turn == false) {
        best_score = INT_MIN;
        for (int i = 0; i < root->num_children; i++) {
            int temp_score = get_min(root->children[i]);
            if (temp_score > best_score) {
                best_score = temp_score;
                best_index = i; 
            }
        }
    } else {
        // Minimizer
        best_score = INT_MAX;
        for (int i = 0; i < root->num_children; i++) {
            int temp_score = get_max(root->children[i]);
            if (temp_score < best_score) {
                best_score = temp_score;
                best_index = i; // En iyi skoru sağlayan çocuğun indeksini güncelle
            }
        }
    }

    return best_index; // En iyi hamlenin indeksini döndür
}

// get_max: Maximizer için en yüksek skoru döndürür
int get_max(TreeNode *node) {
    if (node->num_children == 0||node->num_children==-1) {
        return node->game_state->evaluation; // Yaprak düğüm skoru
    }

    int max_score = INT_MIN;
    for (int i = 0; i < node->num_children; i++) {
        int temp = get_min(node->children[i]);
        if (temp > max_score) {
            max_score = temp;
        }
    }

    return max_score;
}

// get_min: Minimizer için en düşük skoru döndürür
int get_min(TreeNode *node) {
    if (node->num_children == 0||node->num_children==-1) {
        return node->game_state->evaluation; // Yaprak düğüm skoru
    }

    int min_score = INT_MAX;
    for (int i = 0; i < node->num_children; i++) {
        int temp = get_max(node->children[i]);
        if (temp < min_score) {
            min_score = temp;
        }
    }

    return min_score;
}*/
