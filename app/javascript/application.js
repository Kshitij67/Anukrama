// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

console.log("✅ application.js loaded");

import "@hotwired/turbo-rails";
import "controllers";
import * as bootstrap from "bootstrap";
import Sortable from "sortablejs"; // Import Sortable only once

window.Sortable = Sortable; // Make Sortable globally available
console.log("JS LOADED");

// Function to set up the delete bin functionality
function setupDeleteBin() {
  console.log("Setting up delete bin functionality");
  
  const token = document.querySelector('meta[name="csrf-token"]')?.content;
  const deleteBin = document.getElementById('delete-bin');
  
  if (!deleteBin) {
    console.error("Delete bin element not found!");
    return;
  }
  
  console.log("Delete bin found:", deleteBin);
  
  // Make the delete bin a drop target
  Sortable.create(deleteBin, {
    group: 'tasks', // Same group as the task lists
    animation: 150,
    onAdd: function(evt) {
      console.log("Task dropped on delete bin");
      
      const taskId = evt.item.dataset.taskId;
      console.log('Attempting to delete task with ID:', taskId);
      
      // Send delete request to server
      fetch(`/tasks/${taskId}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token,
          'Accept': 'application/json'
        }
      })
      .then(response => {
        console.log('Delete response:', response);
        if (!response.ok) throw new Error('Network response was not ok');
        evt.item.remove(); // Remove the task from the DOM
      })
      .catch(error => {
        console.error('Delete error:', error);
        // The item will stay in the delete bin on error, which is what we want
      });
    }
  });
  
  // Make tasks draggable between columns
  document.querySelectorAll(".list-group").forEach(taskList => {
    console.log("Setting up Sortable for task list:", taskList);
    
    Sortable.create(taskList, {
      group: 'tasks', // Same group as the delete bin
      animation: 150,
      ghostClass: 'sortable-ghost',
      dragClass: 'sortable-drag',
      onStart: function(evt) {
        console.log("Drag started");
        deleteBin.classList.add('active'); // Show delete bin
      },
      onEnd: function(evt) {
        console.log("Drag ended");
        deleteBin.classList.remove('active'); // Hide delete bin
        
        // Only handle status updates if not dropped on delete bin
        if (evt.to !== deleteBin && evt.to !== evt.from) {
          const taskId = evt.item.dataset.taskId;
          const newStatus = evt.to.closest('.status-section').dataset.status;
          
          console.log(`Moving task ${taskId} to status: ${newStatus}`);
          
          const statusMap = {
            'incomplete': 0,
            'ongoing': 1,
            'complete': 2
          };
          
          fetch(`/tasks/${taskId}/update_status`, {
            method: 'PATCH',
            headers: {
              'Content-Type': 'application/json',
              'X-CSRF-Token': token,
              'Accept': 'application/json'
            },
            body: JSON.stringify({ status: statusMap[newStatus] })
          })
          .then(response => {
            if (!response.ok) throw new Error('Network response was not ok');
            return response.json();
          })
          .then(data => {
            console.log("Status updated successfully:", data);
            
            // Apply or remove completed style based on new status
            if (newStatus === 'complete') {
              evt.item.style.textDecoration = 'line-through';
              evt.item.style.color = '#6b7280';
            } else {
              evt.item.style.textDecoration = 'none';
              evt.item.style.color = '#333';
            }
          })
          .catch(error => {
            console.error('Status update error:', error);
            evt.from.appendChild(evt.item); // Revert on error
          });
        }
      }
    });
  });
}

// Ensure we call our setup function when the DOM is loaded
document.addEventListener("DOMContentLoaded", function() {
  console.log("DOM Content Loaded - Setting up Sortable");
  setupDeleteBin();
});

// Also set up when Turbo loads a new page
document.addEventListener("turbo:load", function() {
  console.log("Turbo Loaded - Setting up Sortable");
  setupDeleteBin();
});import * as bootstrap from "bootstrap"
