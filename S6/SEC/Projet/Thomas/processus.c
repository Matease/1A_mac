#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "processus.h"

void initialiser(liste_p *liste_processus)
{
    *liste_processus = NULL;
}


void add(int pid, processus **liste_processus, char **seq)
{
    processus *nouveau_process = malloc(sizeof(processus));
    char *cmd = malloc(sizeof(char) * 256);
    
    while (*seq)
    {
        strcat(cmd, *seq);
        seq++;
        strcat(cmd, " ");
    }
    nouveau_process->cmd = cmd;
    nouveau_process->pid = pid;
    nouveau_process->etat = "Actif";
    nouveau_process->suivant = NULL;
    processus *buffer = *liste_processus;
    if (buffer == NULL)
    {
        nouveau_process->id = 1;
        *liste_processus = nouveau_process;
    }
    else
    {
        nouveau_process->id = 1;
        if (buffer->id > 1)
        {
            nouveau_process->suivant = buffer;
            *liste_processus = nouveau_process;
        }
        else
        {
            while (buffer->suivant != NULL && buffer->suivant->id >= nouveau_process->id)
            {
                nouveau_process->id += 1;
                buffer = buffer->suivant;
            }
            if (buffer->suivant != NULL)
            {
                nouveau_process->suivant = buffer;
                buffer = nouveau_process;
            }
            else
            {
                nouveau_process->id += 1;
                buffer->suivant = nouveau_process;
            }
        }
    }
}


void supprimer(int pid, processus **liste_processus) //supprimer grâce au pid
{
    processus *buffer = *liste_processus;
    processus *precedent = NULL;
    if (buffer->pid == pid)
    {
        *liste_processus = buffer->suivant;
        free(buffer);
    }
    else
    {
        while (buffer != NULL && buffer->pid != pid)
        {
            precedent = buffer;
            buffer = buffer->suivant;
        }
        if (buffer == NULL)
        {
            return;
        }
        else
        {
            precedent->suivant = buffer->suivant;
            free(buffer);
        }
    }
}

void liberer(liste_p *liste_processus)
{
    processus *aliberer;
    processus *buffer = *liste_processus; //on intriduit un tampon pour pouvoir supprimer par la suite 
    while (buffer != NULL)
    {
        aliberer = buffer;
        buffer = buffer->suivant;
        free(aliberer);
    }
    *liste_processus = NULL;
}


void afficher(processus **liste_processus)
{
    processus *buffer = *liste_processus;
    
    if (buffer == NULL)
    {
        printf("Aucun processus en cours\n");
        return;
    }
    
    while (buffer)
    {
        printf("id: %d, pid: %d, état: %s, cmd: %s\n", buffer->id, buffer->pid, buffer->etat, buffer->cmd);
        buffer = buffer->suivant;
    }
}

processus *processus_via_id(int id, liste_p *liste_processus)
{
    processus *buffer = *liste_processus;
    
    while (buffer)
    {
        if (buffer->id == id)
        {
            return buffer;
        }
        
        buffer = buffer->suivant;
    }
    
    return NULL; 
}

processus *processus_via_pid(int pid, liste_p *liste_processus)
{
    processus *buffer = *liste_processus;
    
    while (buffer)
    {
        if (buffer->pid == pid)
        {
            return buffer;
        }
        
        buffer = buffer->suivant;
    }
    
    return NULL; 
}

