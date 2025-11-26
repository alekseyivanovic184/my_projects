#include "tree.h"
#include "connect4.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

TreeNode *init_node(GameState *gs) {

    TreeNode* root = (TreeNode*)malloc(sizeof(TreeNode));
    
    if (root == NULL) return NULL;

    root->game_state = gs;
    root->num_children = -1;
    root->children = NULL;

    return root;
}


void expand_tree(TreeNode *root) {

    if (root == NULL)return;

    if (get_game_status(root->game_state)!=IN_PROGRESS)
    {
        return;
    }

    if(root->num_children == -1) {
        bool moves[root->game_state->width];
        memset(moves,0,root->game_state->width*sizeof(bool));
        int move_num = available_moves(root->game_state, moves);

        if(move_num != 0) {

            root->num_children = move_num;
            root->children = (TreeNode**)malloc(sizeof(TreeNode *) * root->num_children);
            int child_index = 0;
            
            for(int i = 0; i < root->game_state->width; i++) {

                if(moves[i]) {

                    GameState * new_state = make_move(root->game_state,i);
                    root->children[child_index] = init_node(new_state);
                    // free_game_state(root->game_state);
                    child_index++;

                }

            } 

        } else {

            root->num_children = 0;

        }

    } else {

        if (root->num_children != 0)
        {
            for(int i = 0; i < root->num_children; i++) {
            
            expand_tree(root->children[i]);
        
        }
            
        }
  

    }


}
    

    


TreeNode *init_tree(GameState *gs, int depth){
    
    TreeNode* root=init_node(gs);
     
    for(int i=0;i<depth-1;i++){
        
        expand_tree(root);
    }
    
    return root;
}

void free_tree(TreeNode *root) {
    
    if (root == NULL) return;

    for (int i = 0; i < root->num_children; i++) {
        
        if (root->children[i] != NULL) {
            free_tree(root->children[i]);
        }
    }

    if (root->children != NULL) {
        free(root->children);
    }
    if (root->game_state != NULL) {
        free_game_state(root->game_state);
    }
    free(root);
}

int node_count(TreeNode *root) {
    if (root == NULL) return 0;

    int count = 1;

    if (root->num_children == -1 || root->num_children == 0) {
        return count;
    }

    for (int i = 0; i < root->num_children; i++) {
        count += node_count(root->children[i]);
    }

    return count;
}

/*void print_tree(TreeNode *root, int level) {
 if (root == NULL) {
     printf("%*sNULL\n", level * 4, ""); 
     return;
 }

    printf("%*sGameState (Level %d):\n%d", level * 4, "", level,root->game_state->evaluation);
    print_game_state(root->game_state); 

    if (root->num_children == 0) {
     printf("%*sLeaf Node\n%d", (level + 1) * 4, "",root->game_state->evaluation);
     return;
    }

    for (int i = 0; i < root->num_children; i++) {
         printf("%*sChild %d:\n", level * 4, "", i + 1);
         print_tree(root->children[i], level + 1); 
    }
 }*/