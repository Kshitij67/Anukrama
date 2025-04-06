// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

console.log("✅ application.js loaded");

import "@hotwired/turbo-rails";
import "controllers";
import * as bootstrap from "bootstrap";
import Sortable from "sortablejs"; // Import Sortable only once

window.Sortable = Sortable; // Make Sortable globally available
console.log("JS LOADED");

document.addEventListener("turbo:load", () => {
  const token = document.querySelector('meta[name="csrf-token"]')?.content;
  const deleteBin = document.getElementById('delete-bin');

  // Make labels draggable horizontally
  const labelsContainer = document.getElementById("labels-container");
  if (labelsContainer) {
    Sortable.create(labelsContainer, {
      animation: 150,
      ghostClass: "sortable-ghost",
      dragClass: "sortable-drag",
      direction: "horizontal", // Enable horizontal dragging
      onEnd: (event) => {
        console.log("Labels reordered:", event);
        // You can send an AJAX request here to persist the new order of labels if needed
      },
    });
  }

  // Make tasks draggable between labels
  document.querySelectorAll(".list-group").forEach((taskList) => {
    Sortable.create(taskList, {
      group: "tasks", // Allow dragging between task lists
      animation: 150,
      ghostClass: "sortable-ghost",
      dragClass: "sortable-drag",
      onStart: function(evt) {
        deleteBin.classList.add('active');
      },
      onEnd: function(evt) {
        deleteBin.classList.remove('active');

        // Check if the task was dropped on the delete bin
        if (evt.to === deleteBin) {
          const taskId = evt.item.dataset.taskId;

          fetch(`/tasks/${taskId}`, {
            method: 'DELETE',
            headers: {
              'Content-Type': 'application/json',
              'X-CSRF-Token': token,
              'Accept': 'application/json'
            }
          })
          .then(response => {
            if (!response.ok) throw new Error('Network response was not ok');
            evt.item.remove(); // Remove the task from the list
          })
          .catch(error => {
            console.error('Error:', error);
            // Optionally revert the drag if there's an error
            evt.from.appendChild(evt.item);
          });
        } else {
          const taskId = evt.item.dataset.taskId;
          const newStatus = evt.to.closest('.status-section').dataset.status;

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
            console.log("Task status updated successfully");
          })
          .catch(error => {
            console.error('Error:', error);
            evt.from.appendChild(evt.item); // revert on error
          });
        }
      }
    });
  });
});